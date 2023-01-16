defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.UserApiToken
  alias ElixirInternalCertification.Guardian
  alias ElixirInternalCertificationWeb.AuthErrorHandler

  def create(conn, %{"email" => email, "password" => password}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      {:ok, token, _full_claims} = Guardian.encode_and_sign(user)

      user_api_token = UserApiToken.new(%{token: token})

      conn
      |> put_status(:ok)
      |> render("show.json", %{data: user_api_token})
    else
      AuthErrorHandler.auth_error(conn, {:unauthorized, :invalid_email_or_password}, [])
    end
  end

  def create(conn, _params),
    do: AuthErrorHandler.auth_error(conn, {:unprocessable_entity, :missing_arguments}, [])
end
