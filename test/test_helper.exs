Code.put_compiler_option(:warnings_as_errors, true)

{:ok, _} = Application.ensure_all_started(:mimic)

{:ok, _} = Application.ensure_all_started(:ex_machina)

Mimic.copy(Ecto.Adapters.SQL)
Mimic.copy(ElixirInternalCertification.Keyword.Keywords)
Mimic.copy(ElixirInternalCertification.Fetcher.Client.Google)
Mimic.copy(ElixirInternalCertification.Fetcher.Google)

{:ok, _} = Application.ensure_all_started(:wallaby)

ExUnit.start(capture_log: true)
Ecto.Adapters.SQL.Sandbox.mode(ElixirInternalCertification.Repo, :manual)

Application.put_env(:wallaby, :base_url, ElixirInternalCertificationWeb.Endpoint.url())
