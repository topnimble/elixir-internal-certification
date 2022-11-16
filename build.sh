#!/usr/bin/env bash
# exit on error
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
npm install --prefix ./assets
MIX_ENV=prod mix assets.deploy

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite

# Run Ecto migrations
_build/prod/rel/elixir_internal_certification/bin/elixir_internal_certification eval "ElixirInternalCertification.ReleaseTasks.migrate"
