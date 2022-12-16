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

  @doc """
  Creates a keyword.

  ## Examples

      iex> create_keyword(%User{}, %{field: value})
      {:ok, %Keyword{}}

      iex> create_keyword(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_keyword(%User{} = user, attrs \\ %{}) do
    user
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  def create_keywords(%User{id: _user_id} = user, keywords) when is_list(keywords) do
    case keywords_valid?(user, keywords) do
      true ->
        keyword_params = create_params_from_keywords(user, keywords)
        Repo.insert_all(Keyword, keyword_params, returning: true)

      false ->
        :error
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

  defp keywords_valid?(user, keywords) do
    {_valid_changesets, invalid_changesets} =
      keywords
      |> Enum.map(fn keyword ->
        Keyword.changeset(user, %{title: keyword})
      end)
      |> Enum.split_with(fn changeset -> changeset.valid? end)

    Enum.empty?(invalid_changesets)
  end

  defp create_params_from_keywords(user, keywords) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    Enum.map(keywords, fn keyword ->
      %{user_id: user.id, title: keyword, inserted_at: now, updated_at: now}
    end)
  end
end
