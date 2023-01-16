defmodule ElixirInternalCertificationWeb.Api.ErrorViewTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.View

  alias ElixirInternalCertificationWeb.Api.ErrorView

  describe "render/2" do
    test "given an error with code and detail, renders error.json" do
      assert render(ErrorView, "error.json", %{
               code: :unprocessable_entity,
               detail: "missing_arguments"
             }) ==
               %{
                 errors: [
                   %{
                     code: :unprocessable_entity,
                     detail: "missing_arguments"
                   }
                 ]
               }
    end

    test "given an error WITHOUT code and detail, raises Phoenix.Template.UndefinedError" do
      assert_raise Phoenix.Template.UndefinedError, fn ->
        render(ErrorView, "error.json", %{})
      end
    end
  end
end
