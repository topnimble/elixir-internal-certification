defmodule ElixirInternalCertification.Repo do
  use Ecto.Repo,
    otp_app: :elixir_internal_certification,
    adapter: Ecto.Adapters.Postgres
end
