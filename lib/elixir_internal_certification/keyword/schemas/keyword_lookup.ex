defmodule ElixirInternalCertification.Keyword.Schemas.KeywordLookup do
  use Ecto.Schema

  import Ecto.Changeset

  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  schema "keyword_lookups" do
    belongs_to :keyword, Keyword
    field :html, :string
    field :number_of_adwords_advertisers, :integer
    field :number_of_adwords_advertisers_top_position, :integer
    field :urls_of_adwords_advertisers_top_position, {:array, :string}, default: []
    field :number_of_non_adwords, :integer
    field :urls_of_non_adwords, {:array, :string}, default: []
    field :number_of_links, :integer

    timestamps()
  end

  def changeset(keyword_lookup \\ %__MODULE__{}, attrs) do
    keyword_lookup
    |> cast(attrs, [
      :keyword_id,
      :html,
      :number_of_adwords_advertisers,
      :number_of_adwords_advertisers_top_position,
      :urls_of_adwords_advertisers_top_position,
      :number_of_non_adwords,
      :urls_of_non_adwords,
      :number_of_links
    ])
    |> validate_required([
      :keyword_id,
      :html,
      :number_of_adwords_advertisers,
      :number_of_adwords_advertisers_top_position,
      :urls_of_adwords_advertisers_top_position,
      :number_of_non_adwords,
      :urls_of_non_adwords,
      :number_of_links
    ])
    |> assoc_constraint(:keyword)
  end
end
