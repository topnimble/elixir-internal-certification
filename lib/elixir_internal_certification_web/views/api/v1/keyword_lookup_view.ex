defmodule ElixirInternalCertificationWeb.Api.V1.KeywordLookupView do
  use JSONAPI.View, type: "keyword_lookups"

  def fields do
    [
      :id,
      :html,
      :number_of_adwords_advertisers,
      :number_of_adwords_advertisers_top_position,
      :urls_of_adwords_advertisers_top_position,
      :number_of_non_adwords,
      :urls_of_non_adwords,
      :number_of_links,
      :inserted_at,
      :updated_at
    ]
  end
end
