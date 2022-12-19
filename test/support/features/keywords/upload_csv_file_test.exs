defmodule ElixirInternalCertificationWeb.Features.Keywords.UploadCSVFileTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.{Browser, Query}

  alias ElixirInternalCertification.FeatureHelper
  alias ElixirInternalCertification.Keyword.Keywords

  @fixture_path "test/support/fixtures"

  @selectors %{
    upload_button: ".upload-button",
    remove_file_button: ".remove-file-button"
  }

  feature "chooses the CSV file and uploads", %{session: session} do
    user = insert(:user)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> attach_file(Query.file_field("keyword"), path: @fixture_path <> "/assets/keywords.csv")
    |> click(css(@selectors[:upload_button]))
    |> find(css(@selectors[:upload_button], count: 0))

    keywords = Keywords.list_keywords(user)

    assert length(keywords) == 3

    assert equal?(Enum.map(keywords, fn keyword -> keyword.title end), [
             "first keyword",
             "second keyword",
             "third keyword"
           ]) == true
  end

  feature "chooses the CSV file and cancels", %{session: session} do
    user = insert(:user)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> attach_file(Query.file_field("keyword"), path: @fixture_path <> "/assets/keywords.csv")
    |> click(css(@selectors[:remove_file_button]))

    assert Keywords.list_keywords(user) == []
  end
end
