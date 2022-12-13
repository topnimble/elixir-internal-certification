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

  @number_of_max_keywords 1_000

  # @doc """
  # Returns the list of keywords.

  # ## Examples

  #     iex> list_keywords(%User{})
  #     [%Keyword{}, ...]

  # """
  def list_keywords(%User{} = user), do: Repo.all(KeywordQuery.list_keywords_by_user(user))

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
    |> Keyword.changeset(%Keyword{}, attrs)
    |> Repo.insert()
  end

  def create_keywords(%User{id: user_id} = _user, keywords) when is_list(keywords) do
    now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    entries =
      Enum.map(keywords, fn keyword ->
        %{title: keyword, user_id: user_id, inserted_at: now, updated_at: now}
      end)

    Repo.insert_all(Keyword, entries, returning: true)
  end

  def parse_csv!(path) when is_binary(path) do
    keywords =
      path
      |> File.stream!()
      |> CSV.parse_stream(skip_headers: false)
      |> Enum.to_list()
      |> List.flatten()

    if length(keywords) <= @number_of_max_keywords do
      {:ok, keywords}
    else
      {:error, :too_many_keywords}
    end
  end
end
