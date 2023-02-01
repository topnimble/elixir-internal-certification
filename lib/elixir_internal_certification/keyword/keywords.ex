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

  @topic __MODULE__

  def list_keywords(%User{} = user, search_query)
      when is_binary(search_query) and search_query != "" do
    user
    |> KeywordQuery.list_keywords_by_user(search_query)
    |> Repo.all()
  end

  def list_keywords(%User{} = user, _search_query), do: list_keywords(user)

  def list_keywords(%User{} = user) do
    user
    |> KeywordQuery.list_keywords_by_user()
    |> Repo.all()
  end

  def list_keywords_using_url(
        %User{} = user,
        search_query,
        search_query_type,
        search_query_target,
        number_of_occurrences,
        symbol_notation
      ) do
    user
    |> KeywordQuery.list_keywords_by_user_using_url(
      search_query,
      search_query_type,
      search_query_target,
      number_of_occurrences,
      symbol_notation
    )
    |> Repo.all()
  end

  def get_keyword!(id), do: Repo.get!(Keyword, id)

  def get_keyword!(%User{id: user_id} = _user, id) do
    Keyword
    |> Repo.get_by!(id: id, user_id: user_id)
    |> Repo.preload(:keyword_lookup)
  end

  def create_keywords(%User{id: _user_id} = user, keywords) when is_list(keywords) do
    case validate_keywords(user, keywords) do
      {:ok, valid_changesets} ->
        params = create_params_from_changesets(valid_changesets)
        {:ok, Repo.insert_all(Keyword, params, returning: true)}

      {:error, _invalid_changesets} ->
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

  def update_status!(%Keyword{} = keyword, status) do
    keyword
    |> Keyword.update_status_changeset(status)
    |> Repo.update!()
  end

  def find_and_update_keyword(keywords, updated_keyword_id) when is_integer(updated_keyword_id) do
    Enum.map(keywords, fn %Keyword{id: keyword_id} = keyword ->
      if keyword_id == updated_keyword_id do
        Repo.reload(keyword)
      else
        keyword
      end
    end)
  end

  def subscribe_keyword_update(%User{id: user_id} = _user),
    do: Phoenix.PubSub.subscribe(ElixirInternalCertification.PubSub, "#{@topic}_#{user_id}")

  def broadcast_keyword_update(%Keyword{user_id: user_id} = keyword) do
    Phoenix.PubSub.broadcast(
      ElixirInternalCertification.PubSub,
      "#{@topic}_#{user_id}",
      {:updated, keyword}
    )
  end

  defp validate_keywords(user, keywords) do
    {valid_changesets, invalid_changesets} =
      keywords
      |> Enum.map(fn keyword ->
        Keyword.changeset(user, %Keyword{}, %{title: keyword})
      end)
      |> Enum.split_with(fn changeset -> changeset.valid? end)

    if Enum.empty?(invalid_changesets) do
      {:ok, valid_changesets}
    else
      {:error, invalid_changesets}
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
