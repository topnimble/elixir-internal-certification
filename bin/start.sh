#!/bin/sh

bin/elixir_internal_certification eval "ElixirInternalCertification.ReleaseTasks.migrate()"

bin/elixir_internal_certification start
