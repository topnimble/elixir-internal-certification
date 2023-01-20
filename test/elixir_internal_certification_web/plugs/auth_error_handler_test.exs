defmodule ElixirInternalCertificationWeb.AuthErrorHandlerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertificationWeb.AuthErrorHandler

  describe "auth_error/3" do
    test "given an unauthorized error, returns 401 status", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unauthorized, "Invalid email or password"}, [])

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => "Invalid email or password"
                 }
               ]
             }
    end

    test "given an unprocessable entity error, returns 422 status", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unprocessable_entity, "Missing arguments"}, [])

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => "Missing arguments"
                 }
               ]
             }
    end
  end
end
