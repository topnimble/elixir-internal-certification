# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_internal_certification,
  ecto_repos: [ElixirInternalCertification.Repo],
  max_keywords_per_upload: 1_000

# Configures the endpoint
config :elixir_internal_certification, ElixirInternalCertificationWeb.Endpoint,
  health_path: "/_health",
  url: [host: "localhost"],
  render_errors: [
    view: ElixirInternalCertificationWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: ElixirInternalCertification.PubSub,
  live_view: [signing_salt: "DNeFSCDg"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :elixir_internal_certification, ElixirInternalCertification.Mailer,
  adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure dart_sass (the version is required)
config :dart_sass,
  version: "1.49.11",
  app: [
    args: ~w(
      --load-path=./node_modules
      css/app.scss
      ../priv/static/assets/app.css
      ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  app: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir_internal_certification, Oban,
  repo: ElixirInternalCertification.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10]

config :tesla, :adapter, Tesla.Adapter.Hackney

config :elixir_internal_certification, ElixirInternalCertification.Guardian, issuer: "elixir_internal_certification"

config :elixir_internal_certification, ElixirInternalCertificationWeb.AuthenticatedAccessPipeline, module: ElixirInternalCertification.Guardian, error_handler: ElixirInternalCertificationWeb.AuthErrorHandler

config :elixir_internal_certification, ElixirInternalCertificationWeb.UnauthenticatedAccessPipeline, module: ElixirInternalCertification.Guardian, error_handler: ElixirInternalCertificationWeb.AuthErrorHandler

config :jsonapi, remove_links: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
