defmodule ElixirInternalCertificationWeb.Api.V1.UserSessionView do
  use JSONAPI.View, type: "user_sessions"

  def fields do
    [
      :token,
      :token_type
    ]
  end
end
