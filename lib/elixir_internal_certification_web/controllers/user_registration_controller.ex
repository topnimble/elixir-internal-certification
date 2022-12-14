defmodule ElixirInternalCertificationWeb.UserRegistrationController do
  use ElixirInternalCertificationWeb, :controller

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertificationWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
