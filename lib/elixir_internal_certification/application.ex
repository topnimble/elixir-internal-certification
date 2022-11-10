defmodule ElixirInternalCertification.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElixirInternalCertification.Repo,
      # Start the Telemetry supervisor
      ElixirInternalCertificationWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirInternalCertification.PubSub},
      # Start the Endpoint (http/https)
      ElixirInternalCertificationWeb.Endpoint,
      {Oban, oban_config()}
      # Start a worker by calling: ElixirInternalCertification.Worker.start_link(arg)
      # {ElixirInternalCertification.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirInternalCertification.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirInternalCertificationWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Conditionally disable crontab, queues, or plugins here.
  defp oban_config do
    Application.get_env(:elixir_internal_certification, Oban)
  end
end
