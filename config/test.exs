import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :elixir_internal_certification, ElixirInternalCertification.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "elixir_internal_certification_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_internal_certification, ElixirInternalCertificationWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0OOHdKyBySwg/kOAuoAAqTe7vAjhaY6LyS6L1LM3CnX7avvBErW3ogcL+5e26abz",
  server: true

config :elixir_internal_certification, :sql_sandbox, true

config :wallaby,
  otp_app: :elixir_internal_certification,
  chromedriver: [headless: System.get_env("CHROME_HEADLESS", "true") === "true"],
  screenshot_dir: "tmp/wallaby_screenshots",
  screenshot_on_failure: true

# In test we don't send emails.
config :elixir_internal_certification, ElixirInternalCertification.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

config :elixir_internal_certification, Oban, crontab: false, queues: false, plugins: false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configurations for ExVCR
config :exvcr,
  vcr_cassette_library_dir: "test/support/fixtures/vcr_cassettes",
  ignore_localhost: true

config :elixir_internal_certification, ElixirInternalCertification.Guardian,
  secret_key: "RyXHyjJcFLKRSYDJ1CL8eUwcq7+j1xt5MUH5W+wqMi0aZR5QM9QAM9NYjtEepLCm"
