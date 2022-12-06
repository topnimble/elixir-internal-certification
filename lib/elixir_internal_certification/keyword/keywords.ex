defmodule ElixirInternalCertification.Keyword.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Repo
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Returns the list of keywords.

  ## Examples

      iex> list_keywords()
      [%Keyword{}, ...]

  """
  def list_keywords do
    Repo.all(Keyword)
  end

  @doc """
  Gets a single keyword.

  Raises `Ecto.NoResultsError` if the Keyword does not exist.

  ## Examples

      iex> get_keyword!(123)
      %Keyword{}

      iex> get_keyword!(456)
      ** (Ecto.NoResultsError)

  """
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
    |> Keyword.changeset(%Keyword{}, attrs)
    |> Repo.insert()
  end

  def save_keyword_to_database(%User{} = user, keyword) do
    create_keyword(user, %{
      title: keyword
    })
  end

  def parse_csv!(path, callback) when is_binary(path) and is_function(callback) do
    path
    |> File.stream!(read_ahead: 100)
    |> CSV.parse_stream()
    |> Stream.map(fn line_of_keywords ->
      callback.(line_of_keywords)
    end)
    |> Stream.run()
  end

end
