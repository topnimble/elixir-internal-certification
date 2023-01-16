defmodule ElixirInternalCertificationWeb.AuthErrorHandlerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertificationWeb.AuthErrorHandler

  describe "auth_error/3" do
    test "given an unauthorized error, returns 401 status", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unauthorized, :invalid_email_or_password}, [])

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthorized",
                   "detail" => "invalid_email_or_password"
                 }
               ]
             }
    end

    test "given an unprocessable entity error, returns 422 status", %{conn: conn} do
      conn = AuthErrorHandler.auth_error(conn, {:unprocessable_entity, :missing_arguments}, [])

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => "missing_arguments"
                 }
               ]
             }
    end
  end
end
