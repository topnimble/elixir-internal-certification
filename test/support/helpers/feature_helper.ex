defmodule ElixirInternalCertification.FeatureHelper do
  import ElixirInternalCertification.Factory
  import Wallaby.{Browser, Query}

  alias ElixirInternalCertificationWeb.Router.Helpers, as: Routes

  @selectors %{
    email_field: "input#user_email",
    password_field: "input#user_password",
    log_in_button: ".log-in-button"
  }

  def authenticated_user(session, user \\ insert(:user)) do
    session
    |> visit(Routes.user_session_path(ElixirInternalCertificationWeb.Endpoint, :new))
    |> fill_in(css(@selectors[:email_field]), with: user.email)
    |> fill_in(css(@selectors[:password_field]), with: user.password)
    |> click(css(@selectors[:log_in_button]))
  end
end
