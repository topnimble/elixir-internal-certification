defmodule ElixirInternalCertificationWeb.AuthErrorHandler do
  @behaviour Guardian.Plug.ErrorHandler

  use Phoenix.Controller

  import Plug.Conn

  alias ElixirInternalCertificationWeb.Api.ErrorView

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, reason}, _opts) when type in [:unauthenticated, :unauthorized] do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: type,
      detail: Phoenix.Naming.humanize(reason)
    })
    |> halt()
  end

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{
      code: type,
      detail: Phoenix.Naming.humanize(reason)
    })
    |> halt()
  end
end
