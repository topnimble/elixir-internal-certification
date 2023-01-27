defmodule ElixirInternalCertificationWeb.Api.V1.KeywordView do
  use JSONAPI.View, type: "keywords"

  alias ElixirInternalCertificationWeb.Api.V1.KeywordLookupView

  def fields do
    [
      :id,
      :title,
      :status,
      :inserted_at,
      :updated_at
    ]
  end

  def relationships, do: [keyword_lookup: {KeywordLookupView, :include}]
end
