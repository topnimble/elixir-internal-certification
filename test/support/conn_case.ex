defmodule ElixirInternalCertificationWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ElixirInternalCertificationWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  import ElixirInternalCertification.Factory

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Guardian

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

      use Mimic

      use Oban.Testing, repo: ElixirInternalCertification.Repo

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ElixirInternalCertificationWeb.ConnCase
      import ElixirInternalCertification.Factory
      import ElixirInternalCertification.TestHelper

      alias ElixirInternalCertificationWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ElixirInternalCertificationWeb.Endpoint
    end
  end

  setup tags do
    ElixirInternalCertification.DataCase.setup_sandbox(tags)

    base_conn = Phoenix.ConnTest.build_conn()

    cond do
      tags[:register_and_log_in_user] ->
        register_and_log_in_user(%{conn: base_conn})

      tags[:register_and_log_in_user_with_token] ->
        register_and_log_in_user_with_token(%{conn: base_conn})

      true ->
        {:ok, conn: base_conn}
    end
  end

  @doc """
  Setup helper that registers and logs in users.

      setup :register_and_log_in_user

  It stores an updated connection and a registered user in the
  test context.
  """
  def register_and_log_in_user(%{conn: conn}) do
    user = insert(:user)
    %{conn: log_in_user(conn, user), user: user}
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    token = Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def register_and_log_in_user_with_token(%{conn: conn}) do
    user = insert(:user)
    %{conn: log_in_user_with_token(conn, user), user: user}
  end

  def log_in_user_with_token(conn, user) do
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)
    Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token)
  end
end
