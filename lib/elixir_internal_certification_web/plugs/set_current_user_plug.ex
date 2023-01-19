defmodule ElixirInternalCertificationWeb.SetCurrentUserPlug do
  @behaviour Plug

  import Plug.Conn

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Guardian.Plug
  alias ElixirInternalCertificationWeb.AuthErrorHandler

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    case Plug.current_resource(conn) do
      %User{} = current_user ->
        assign(conn, :current_user, current_user)

      _ ->
        conn
        |> AuthErrorHandler.auth_error({:unauthenticated, :unauthenticated}, [])
        |> halt()
    end
  end
end
