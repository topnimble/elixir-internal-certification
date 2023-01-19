defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias Ecto.ULID
  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Guardian

  describe "POST create/2" do
    test "given a valid email and password, returns a user API token", %{conn: conn} do
      %User{email: email, password: password} = _user = insert(:user)

      params = %{
        email: email,
        password: password
      }

      expect(ULID, :generate, fn -> "01GQ45DK0QQEWQY6J01HV3BWQW" end)

      token = "123456"
      expect(Guardian, :encode_and_sign, fn _resource -> {:ok, token, %{}} end)

      conn = post(conn, Routes.api_v1_user_session_path(conn, :create), params)

      assert json_response(conn, 200) == %{
               "data" => %{
                 "attributes" => %{
                   "token" => token,
                   "token_type" => "Bearer"
                 },
                 "id" => "01GQ45DK0QQEWQY6J01HV3BWQW",
                 "relationships" => %{},
                 "type" => "user_sessions"
               },
               "included" => []
             }
    end

    test "given a valid email but INVALID password, returns 401", %{conn: conn} do
      %User{email: email, password: password} = _user = insert(:user)

      params = %{
        email: email,
        password: password <> "_invalid"
      }

      reject(Guardian, :encode_and_sign, 1)

      conn = post(conn, Routes.api_v1_user_session_path(conn, :create), params)

      assert json_response(conn, 401) == %{
               "errors" => [%{"code" => "unauthorized", "detail" => "Invalid email or password"}]
             }
    end

    test "given an INVALID email and INVALID password", %{conn: conn} do
      params = %{
        email: "invalid_email@example.com",
        password: "invalid_password"
      }

      reject(Guardian, :encode_and_sign, 1)

      conn = post(conn, Routes.api_v1_user_session_path(conn, :create), params)

      assert json_response(conn, 401) == %{
               "errors" => [%{"code" => "unauthorized", "detail" => "Invalid email or password"}]
             }
    end

    test "given MISSING email and password", %{conn: conn} do
      params = %{}

      reject(Guardian, :encode_and_sign, 1)

      conn = post(conn, Routes.api_v1_user_session_path(conn, :create), params)

      assert json_response(conn, 422) == %{
               "errors" => [%{"code" => "unprocessable_entity", "detail" => "Missing arguments"}]
             }
    end
  end
end
