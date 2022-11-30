defmodule ElixirInternalCertificationWeb.UserSessionControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  setup do
    %{user: insert(:user)}
  end

  describe "GET /users/log_in" do
    test "given an unauthenticated user, renders log in page", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
    end

    test "given an authenticated user, redirects to the root page", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/log_in" do
    test "given valid data, logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => user.password}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn_2 = get(conn, "/")
      response = html_response(conn_2, 200)
      assert response =~ user.email
      assert response =~ "Log out</a>"
    end

    test "given valid data with remember me, logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => user.password,
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_elixir_internal_certification_web_user_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "given valid data with return to, logs the user in", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => user.password
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "given INVALID data, emits error message with invalid credentials", %{
      conn: conn,
      user: user
    } do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "given an authenticated user, logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "given an unauthenticated user, logs the user out", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
