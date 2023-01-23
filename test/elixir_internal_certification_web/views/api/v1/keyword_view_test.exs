defmodule ElixirInternalCertificationWeb.Api.V1.KeywordViewTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertificationWeb.Api.V1.KeywordView

  describe "fields/0" do
    test "returns a list of attribute fields" do
      assert KeywordView.fields() == [
               :id,
               :title,
               :status
             ]
    end
  end
end
