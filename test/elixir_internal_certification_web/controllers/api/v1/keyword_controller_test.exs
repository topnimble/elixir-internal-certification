defmodule ElixirInternalCertificationWeb.Api.V1.KeywordControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext

  alias ElixirInternalCertification.Guardian

  @fixture_path "test/support/fixtures"

  setup %{conn: conn} do
    user = insert(:user)

    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)

    conn = put_req_header(conn, "authorization", "Bearer " <> token)

    %{conn: conn, user: user}
  end

  describe "POST create/2" do
    test "given a valid CSV file, returns 200 status", %{conn: conn} do
      params = %{file: uploaded_file("/assets/keywords.csv")}

      conn = post(conn, Routes.api_v1_keyword_path(conn, :create), params)

      assert %{
               "data" => [
                 %{
                   "attributes" => %{"id" => _, "title" => "first keyword"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{"id" => _, "title" => "second keyword"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{"id" => _, "title" => "third keyword"},
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "given a file with INVALID data, returns 422 status", %{conn: conn} do
      params = %{file: uploaded_file("/assets/invalid.csv")}

      conn = post(conn, Routes.api_v1_keyword_path(conn, :create), params)

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => dgettext("errors", "You have selected file with invalid data")
                 }
               ]
             }
    end

    test "given MISSING CSV file argument, returns 422 status", %{conn: conn} do
      params = %{}

      conn = post(conn, Routes.api_v1_keyword_path(conn, :create), params)

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" => dgettext("errors", "Missing arguments")
                 }
               ]
             }
    end
  end

  defp uploaded_file(path) do
    full_path = Path.join([@fixture_path, path])

    %Plug.Upload{
      path: full_path,
      filename: Path.basename(full_path),
      content_type: MIME.from_path(full_path)
    }
  end
end
