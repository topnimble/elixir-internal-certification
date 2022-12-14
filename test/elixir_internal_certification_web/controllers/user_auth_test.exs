defmodule ElixirInternalCertificationWeb.UserAuthTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertificationWeb.UserAuth

  @remember_me_cookie "_elixir_internal_certification_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(
        :secret_key_base,
        ElixirInternalCertificationWeb.Endpoint.config(:secret_key_base)
      )
      |> init_test_session(%{})

    %{user: insert(:user), conn: conn}
  end

  describe "log_in_user/3" do
    test "given an unauthenticated user, stores the user token in the session", %{
      conn: conn,
      user: user
    } do
      conn = UserAuth.log_in_user(conn, user)
      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(token)
    end

    test "given an unauthenticated user, clears everything previously stored in the session", %{
      conn: conn,
      user: user
    } do
      conn = conn |> put_session(:to_be_removed, "value") |> UserAuth.log_in_user(user)
      assert get_session(conn, :to_be_removed) == nil
    end

    test "given an unauthenticated user, redirects to the configured path", %{
      conn: conn,
      user: user
    } do
      conn = conn |> put_session(:user_return_to, "/hello") |> UserAuth.log_in_user(user)
      assert redirected_to(conn) == "/hello"
    end

    test "given an unauthenticated user, writes a cookie if remember_me is configured", %{
      conn: conn,
      user: user
    } do
      conn = conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_user/1" do
    test "given an authenticated user, erases session and cookies", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> put_req_cookie(@remember_me_cookie, user_token)
        |> fetch_cookies()
        |> UserAuth.log_out_user()

      assert get_session(conn, :user_token) == nil
      assert conn.cookies[@remember_me_cookie] == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(user_token) == nil
    end

    test "given an authenticated user, broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "users_sessions:abcdef-token"
      ElixirInternalCertificationWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> UserAuth.log_out_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "given an unauthenticated user, erases session and cookies", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UserAuth.log_out_user()
      assert get_session(conn, :user_token) == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_user/2" do
    test "given a session, authenticates user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token) |> UserAuth.fetch_current_user([])
      assert conn.assigns.current_user.id == user.id
    end

    test "given a cookie, authenticates user", %{conn: conn, user: user} do
      logged_in_conn =
        conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

      user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UserAuth.fetch_current_user([])

      assert get_session(conn, :user_token) == user_token
      assert conn.assigns.current_user.id == user.id
    end

    test "given data is MISSING, does NOT authenticate", %{conn: conn, user: user} do
      _ = Accounts.generate_user_session_token(user)
      conn = UserAuth.fetch_current_user(conn, [])
      assert get_session(conn, :user_token) == nil
      assert conn.assigns.current_user == nil
    end
  end

  describe "redirect_if_user_is_authenticated/2" do
    test "given an authenticated user, redirects to the root page", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "given an unauthenticated user, does NOT redirect", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_authenticated(conn, [])
      assert conn.halted == false
      assert conn.status == nil
    end
  end

  describe "require_authenticated_user/2" do
    test "given an unauthenticated user, redirects to the log in page", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "given an unauthenticated user, stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn.halted
      assert get_session(halted_conn, :user_return_to) == "/foo"

      halted_conn_2 =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_2.halted
      assert get_session(halted_conn_2, :user_return_to) == "/foo?bar=baz"

      halted_conn_3 =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert halted_conn_3.halted
      assert get_session(halted_conn_3, :user_return_to) == nil
    end

    test "given an authenticated user, does NOT redirect", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.require_authenticated_user([])
      assert conn.halted == false
      assert conn.status == nil
    end
  end
end
