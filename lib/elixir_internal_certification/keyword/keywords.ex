defmodule ElixirInternalCertification.Keyword.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Queries.KeywordQuery
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Repo
  alias NimbleCSV.RFC4180, as: CSV

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  # @doc """
  # Returns the list of keywords.

  # ## Examples

  #     iex> list_keywords(%User{})
  #     [%Keyword{}, ...]

  # """
  def list_keywords(%User{} = user), do: Repo.all(KeywordQuery.list_keywords_by_user(user))

  def get_keyword!(id), do: Repo.get!(Keyword, id)

  def create_keywords(%User{id: _user_id} = user, keywords) when is_list(keywords) do
    case validate_keywords(user, keywords) do
      {true, valid_changesets} ->
        params = create_params_from_changesets(valid_changesets)
        {:ok, Repo.insert_all(Keyword, params, returning: true)}

      {false, _invalid_changesets} ->
        {:error, :invalid_data}
    end
  end

  def parse_csv!(path) when is_binary(path) do
    keywords =
      path
      |> File.stream!()
      |> CSV.parse_stream(skip_headers: false)
      |> Enum.to_list()
      |> List.flatten()

    if length(keywords) <= @max_keywords_per_upload do
      {:ok, keywords}
    else
      {:error, :too_many_keywords}
    end
  end

  def update_status(%Keyword{} = keyword, status) do
    keyword
    |> Keyword.update_status_changeset(status)
    |> Repo.update()
  end

  defp validate_keywords(user, keywords) do
    {valid_changesets, invalid_changesets} =
      keywords
      |> Enum.map(fn keyword ->
        Keyword.changeset(user, %Keyword{}, %{title: keyword})
      end)
      |> Enum.split_with(fn changeset -> changeset.valid? end)

    if Enum.empty?(invalid_changesets) do
      {true, valid_changesets}
    else
      {false, invalid_changesets}
    end
  end

  defp create_params_from_changesets(changesets) when is_list(changesets) do
    entries =
      Enum.map(changesets, fn changeset ->
        Ecto.Changeset.apply_changes(changeset)
      end)

    fields = Keyword.__schema__(:fields)
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    Enum.map(entries, fn entry ->
      entry
      |> Map.take(fields)
      |> Map.delete(:id)
      |> Map.put(:inserted_at, now)
      |> Map.put(:updated_at, now)
    end)
  end
end
