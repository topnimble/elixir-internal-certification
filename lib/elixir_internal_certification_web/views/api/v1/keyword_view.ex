defmodule ElixirInternalCertificationWeb.Api.V1.KeywordView do
  use JSONAPI.View, type: "keywords"

  def fields do
    [
      :id,
      :title
    ]
  end
end
