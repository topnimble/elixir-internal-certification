defmodule ElixirInternalCertificationWeb.UnauthenticatedAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :elixir_internal_certification

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureNotAuthenticated
end
