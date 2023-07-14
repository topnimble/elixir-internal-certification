defmodule ElixirInternalCertification.Keyword.Schemas.AdvancedSearch do
  use Ecto.Schema

  alias Ecto.ULID

  embedded_schema do
    field :search_query, :string
    field :search_query_type, :string
    field :search_query_target, :string
    field :number_of_occurrences, :integer
    field :symbol_notation, :string
  end

  def new(
        %{
          "search_query" => search_query,
          "search_query_type" => search_query_type,
          "search_query_target" => search_query_target
        } = attrs
      ) do
    %__MODULE__{
      id: ULID.generate(),
      search_query: search_query,
      search_query_type: search_query_type,
      search_query_target: search_query_target,
      number_of_occurrences: attrs["number_of_occurrences"],
      symbol_notation: attrs["symbol_notation"]
    }
  end
end
