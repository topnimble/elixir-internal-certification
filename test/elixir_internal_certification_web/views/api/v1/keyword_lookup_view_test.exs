defmodule ElixirInternalCertificationWeb.Api.V1.KeywordLookupViewTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertificationWeb.Api.V1.KeywordLookupView

  describe "fields/0" do
    test "returns a list of attribute fields" do
      assert KeywordLookupView.fields() == [
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
end
