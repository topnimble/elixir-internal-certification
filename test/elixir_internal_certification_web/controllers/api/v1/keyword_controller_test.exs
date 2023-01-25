defmodule ElixirInternalCertificationWeb.Api.V1.KeywordControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext

  alias ElixirInternalCertification.Keyword.Keywords

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  @fixture_path "test/support/fixtures"

  setup [:register_and_log_in_user_with_token]

  describe "POST create/2" do
    test "given a valid CSV file, returns 200 status", %{conn: conn} do
      params = %{file: uploaded_file("/assets/keywords.csv")}

      conn = post(conn, Routes.api_v1_keyword_path(conn, :create), params)

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "id" => _,
                     "inserted_at" => _,
                     "status" => "new",
                     "title" => "first keyword",
                     "updated_at" => _
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => _,
                     "inserted_at" => _,
                     "status" => "new",
                     "title" => "second keyword",
                     "updated_at" => _
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => _,
                     "inserted_at" => _,
                     "status" => "new",
                     "title" => "third keyword",
                     "updated_at" => _
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "given a file with more than 1,000 keywords, returns 422 status", %{conn: conn} do
      params = %{file: uploaded_file("/assets/keywords.csv")}

      expect(Keywords, :parse_csv!, fn _ -> {:error, :too_many_keywords} end)

      conn = post(conn, Routes.api_v1_keyword_path(conn, :create), params)

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "code" => "unprocessable_entity",
                   "detail" =>
                     dgettext(
                       "errors",
                       "You have selected file with more than %{max_keywords_per_upload} keywords",
                       max_keywords_per_upload: @max_keywords_per_upload
                     )
                 }
               ]
             }
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
                   "detail" => dgettext("errors", "Missing input file argument")
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
