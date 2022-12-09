defmodule ElixirInternalCertificationWeb.Features.Accounts.AuthenticationTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.{Browser, Query}

  alias ElixirInternalCertification.Account.Schemas.User

  @selectors %{
    email_field: "input#user_email",
    password_field: "input#user_password",
    log_in_button: ".log-in-button",
    user_menu: ".user-menu",
    log_out_button: ".log-out-button"
  }

  feature "views log in page", %{session: session} do
    session
    |> visit(Routes.user_session_path(ElixirInternalCertificationWeb.Endpoint, :new))
    |> assert_has(Query.text("Email"))
    |> assert_has(Query.text("Password"))
    |> assert_has(Query.text("Keep me logged in for 60 days"))
  end

  feature "logs in and logs out", %{session: session} do
    %User{email: email, password: password} = insert(:user)

    session
    |> visit(Routes.user_session_path(ElixirInternalCertificationWeb.Endpoint, :new))
    |> fill_in(css(@selectors[:email_field]), with: email)
    |> fill_in(css(@selectors[:password_field]), with: password)
    |> click(css(@selectors[:log_in_button]))
    |> assert_has(css(".alert.alert-info", text: "Logged in successfully"))
    |> click(css(@selectors[:user_menu]))
    |> click(css(@selectors[:log_out_button]))
    |> assert_has(css(".alert.alert-info", text: "Logged out successfully"))
  end
end
