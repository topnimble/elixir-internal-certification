defmodule ElixirInternalCertificationWeb.LiveHelpersTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertificationWeb.LiveHelpers
  alias Phoenix.LiveView.Socket

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

  describe "show_button/1" do
    test "given a keyword with `new` status, returns a spinner icon" do
      keyword = insert(:keyword, status: :new)

      assert render_component(&LiveHelpers.show_button/1, keyword: keyword) ==
               ~S(<div class="spinner-border spinner-border-sm" role="status">
  <span class="visually-hidden">Processing...</span>
</div>)
    end

    test "given a keyword with `pending` status, returns a spinner icon" do
      keyword = insert(:keyword, status: :pending)

      assert render_component(&LiveHelpers.show_button/1, keyword: keyword) ==
               ~S(<div class="spinner-border spinner-border-sm" role="status">
  <span class="visually-hidden">Processing...</span>
</div>)
    end

    test "given a keyword with `completed` status, returns a show button" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword, status: :completed)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      keyword = ElixirInternalCertification.Repo.preload(keyword, :keyword_lookup)

      assert render_component(&LiveHelpers.show_button/1, keyword: keyword) ==
               ~s(<a data-phx-link="redirect" data-phx-link-state="push" href="/keywords/#{keyword_id}">Show</a>)
    end

    test "given a keyword with `failed` status, returns empty" do
      keyword = insert(:keyword, status: :failed)

      assert render_component(&LiveHelpers.show_button/1, keyword: keyword) == ""
    end
  end

  describe "status_badge/1" do
    test "given a keyword with `new` status, returns a badge" do
      keyword = insert(:keyword, status: :new)

      assert render_component(&LiveHelpers.status_badge/1, keyword: keyword) ==
               ~S(<span class="badge rounded-pill bg-secondary">New</span>)
    end

    test "given a keyword with `pending` status, returns a badge" do
      keyword = insert(:keyword, status: :pending)

      assert render_component(&LiveHelpers.status_badge/1, keyword: keyword) ==
               ~S(<span class="badge rounded-pill bg-info">Pending</span>)
    end

    test "given a keyword with `completed` status, returns a badge" do
      keyword = insert(:keyword, status: :completed)

      assert render_component(&LiveHelpers.status_badge/1, keyword: keyword) ==
               ~S(<span class="badge rounded-pill bg-success">Completed</span>)
    end

    test "given a keyword with `failed` status, returns a badge" do
      keyword = insert(:keyword, status: :failed)

      assert render_component(&LiveHelpers.status_badge/1, keyword: keyword) ==
               ~S(<span class="badge rounded-pill bg-danger">Failed</span>)
    end
  end
end
