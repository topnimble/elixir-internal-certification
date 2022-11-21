defmodule ElixirInternalCertificationWeb.RouterHelper do
  def health_path do
    Application.get_env(:elixir_internal_certification, ElixirInternalCertificationWeb.Endpoint)[
      :health_path
    ]
  end
end
