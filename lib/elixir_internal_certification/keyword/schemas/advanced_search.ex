defmodule ElixirInternalCertification.Keyword.Schemas.AdvancedSearch do
  use Ecto.Schema

  alias Ecto.ULID

  @symbol_notations [:>, :>=, :<, :<=, :=]

  embedded_schema do
    field :search_query, :string
    field :search_query_type, :string
    field :search_query_target, :string
    field :number_of_occurrences, :integer
    field :symbol_notation, Ecto.Enum, values: @symbol_notations
  end

  def new(attrs) do
    %__MODULE__{
      id: ULID.generate(),
      search_query: attrs["search_query"],
      search_query_type: attrs["search_query_type"],
      search_query_target: attrs["search_query_target"],
      number_of_occurrences: attrs["number_of_occurrences"],
      symbol_notation: attrs["symbol_notation"]
    }
  end
end
