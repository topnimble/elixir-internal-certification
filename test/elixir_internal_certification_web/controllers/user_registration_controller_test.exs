defmodule ElixirInternalCertificationWeb.UserRegistrationControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  describe "GET /users/register" do
    test "given an unauthenticated user, renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in</a>"
      assert response =~ "Register</a>"
    end

    test "given an authenticated user, redirects to the root page", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    test "given valid data, creates account and logs the user in", %{conn: conn} do
      %{email: email} = params = params_for(:user)

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => params
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn_2 = get(conn, "/")
      response = html_response(conn_2, 200)
      assert response =~ email
      assert response =~ "Log out</a>"
    end

    test "given INVALID data, render errors", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end
