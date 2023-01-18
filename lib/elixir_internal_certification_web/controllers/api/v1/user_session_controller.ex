defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.{User, UserApiToken}
  alias ElixirInternalCertification.Guardian
  alias ElixirInternalCertificationWeb.AuthErrorHandler

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %User{} = user ->
        {:ok, token, _full_claims} = Guardian.encode_and_sign(user)

        user_api_token = UserApiToken.new(%{token: token})

        conn
        |> put_status(:ok)
        |> render("show.json", %{data: user_api_token})

      _ ->
        AuthErrorHandler.auth_error(conn, {:unauthorized, "Invalid email or password"}, [])
    end
  end

  def create(conn, _params),
    do: AuthErrorHandler.auth_error(conn, {:unprocessable_entity, "Missing arguments"}, [])
end
