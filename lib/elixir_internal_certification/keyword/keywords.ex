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

  @max_number_of_keywords_per_csv_file Application.compile_env!(
                                         :elixir_internal_certification,
                                         :max_number_of_keywords_per_csv_file
                                       )

  # @doc """
  # Returns the list of keywords.

  # ## Examples

  #     iex> list_keywords(%User{})
  #     [%Keyword{}, ...]

  # """
  def list_keywords(%User{} = user), do: Repo.all(KeywordQuery.list_keywords_by_user(user))

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

    if length(keywords) <= @max_number_of_keywords_per_csv_file do
      {:ok, keywords}
    else
      {:error, :too_many_keywords}
    end
  end
end
