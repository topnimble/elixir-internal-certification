defmodule ElixirInternalCertificationWeb.AuthenticatedAccessPipeline do
  use Guardian.Plug.Pipeline, otp_app: :elixir_internal_certification

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug ElixirInternalCertificationWeb.SetCurrentUserPlug
end
