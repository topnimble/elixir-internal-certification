defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Guardian
  alias ElixirInternalCertificationWeb.AuthErrorHandler

  def create(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      {:ok, token, _full_claims} = Guardian.encode_and_sign(user)

      conn
      |> put_status(:ok)
      |> render("show.json", %{data:
        user
        |> Map.put(:token, token)
        |> Map.put(:token_type, "Bearer")
      })
    else
      AuthErrorHandler.auth_error(conn, {:unauthenticated, :invalid_email_or_password}, [])
    end
  end
end
