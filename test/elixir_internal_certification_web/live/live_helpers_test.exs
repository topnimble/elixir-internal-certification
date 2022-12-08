defmodule ElixirInternalCertificationWeb.LiveHelpersTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true
  use Phoenix.Component

  alias ElixirInternalCertificationWeb.LiveHelpers
  alias Phoenix.LiveView.Socket
  alias ElixirInternalCertification.Account.Schemas.User

  setup %{conn: conn} do
    %{conn: conn, socket: %Socket{}}
  end

  describe "set_current_user_to_socket/2" do
    test "given a session with user token assigned, returns a socket with current user assigned", %{
      conn: conn,
      socket: socket
    } do
      %User{id: user_id} = user = insert(:user)
      conn = log_in_user(conn, user)
      session = get_session(conn)

      socket = LiveHelpers.set_current_user_to_socket(socket, session)

      assert %User{id: ^user_id} = socket.assigns.current_user
    end

    test "given a session with NO user token assigned, raises FunctionClauseError", %{
      socket: socket
    } do
      assert_raise FunctionClauseError, fn ->
        LiveHelpers.set_current_user_to_socket(socket, %{})
      end
    end
  end

  describe "get_current_user_from_socket/1" do
    test "given a socket with current user assigned, returns the current user", %{socket: socket} do
      %User{id: user_id} = user = insert(:user)
      socket = assign_new(socket, :current_user, fn -> user end)

      assert %User{id: ^user_id} = LiveHelpers.get_current_user_from_socket(socket)
    end

    test "given a socket with NO current user assigned, raises FunctionClauseError", %{
      socket: socket
    } do
      assert_raise FunctionClauseError, fn ->
        LiveHelpers.get_current_user_from_socket(socket)
      end
    end
  end
end
