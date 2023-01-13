defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionViewTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertificationWeb.Api.V1.UserSessionView

  describe "fields/0" do
    test "returns a list of attribute fields" do
      assert UserSessionView.fields() == [
               :token,
               :token_type
             ]
    end
  end
end
