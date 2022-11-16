#!/bin/sh

_build/prod/rel/elixir_internal_certification/bin/elixir_internal_certification eval "ElixirInternalCertification.ReleaseTasks.migrate()"

_build/prod/rel/elixir_internal_certification/bin/elixir_internal_certification start
