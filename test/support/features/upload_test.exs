defmodule ElixirInternalCertificationWeb.Features.UploadTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.{Browser, Query}

  alias ElixirInternalCertification.FeatureHelper

  @fixture_path "test/support/fixtures"

  @selectors %{
    upload_button: ".upload-button"
  }

  feature "uploads the CSV file", %{session: session} do
    session
    |> FeatureHelper.authenticated_user()
    |> visit(Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> attach_file(Query.file_field("keyword"), path: @fixture_path <> "/assets/keywords.csv")
    |> click(css(@selectors[:upload_button]))
  end
end
