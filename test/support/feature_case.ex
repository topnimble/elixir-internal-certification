defmodule ElixirInternalCertificationWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature
      use Mimic

      import ElixirInternalCertification.Factory
      import ElixirInternalCertification.TestHelper
      import ElixirInternalCertificationWeb.Gettext

      alias ElixirInternalCertification.Repo
      alias ElixirInternalCertificationWeb.Endpoint
      alias ElixirInternalCertificationWeb.Router.Helpers, as: Routes

      @moduletag :feature_test
    end
  end
end
