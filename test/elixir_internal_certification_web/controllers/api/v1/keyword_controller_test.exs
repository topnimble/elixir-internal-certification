defmodule ElixirInternalCertificationWeb.Api.V1.KeywordControllerTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  @fixture_path "test/support/fixtures"

  describe "GET index/2" do
    @tag :register_and_log_in_user_with_token
    test "lists all keywords", %{conn: conn, user: user} do
      another_user = insert(:user)

      %Keyword{id: first_keyword_id} =
        _first_keyword =
        insert(:keyword,
          user: user,
          title: "first keyword",
          inserted_at: ~N[2023-01-01 00:00:00],
          updated_at: ~N[2023-01-01 00:00:00]
        )

      %Keyword{id: second_keyword_id} =
        _second_keyword =
        insert(:keyword,
          user: user,
          title: "second keyword",
          inserted_at: ~N[2023-01-01 00:00:00],
          updated_at: ~N[2023-01-01 00:00:00]
        )

      %Keyword{id: third_keyword_id} =
        _third_keyword =
        insert(:keyword,
          user: user,
          title: "third keyword",
          inserted_at: ~N[2023-01-01 00:00:00],
          updated_at: ~N[2023-01-01 00:00:00]
        )

      %Keyword{id: fourth_keyword_id} =
        _fourth_keyword =
        insert(:keyword,
          user: user,
          title: "fourth keyword",
          inserted_at: ~N[2023-01-01 00:00:00],
          updated_at: ~N[2023-01-01 00:00:00]
        )

      %Keyword{id: fifth_keyword_id} =
        _fifth_keyword =
        insert(:keyword,
          user: user,
          title: "fifth keyword",
          inserted_at: ~N[2023-01-01 00:00:00],
          updated_at: ~N[2023-01-01 00:00:00]
        )

      _another_keyword = insert(:keyword, user: another_user, title: "another keyword")

      params = %{}

      conn = get(conn, Routes.api_v1_keyword_path(conn, :index), params)

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "id" => fifth_keyword_id,
                     "inserted_at" => "2023-01-01T00:00:00",
                     "status" => "new",
                     "title" => "fifth keyword",
                     "updated_at" => "2023-01-01T00:00:00"
                   },
                   "id" => to_string(fifth_keyword_id),
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => fourth_keyword_id,
                     "inserted_at" => "2023-01-01T00:00:00",
                     "status" => "new",
                     "title" => "fourth keyword",
                     "updated_at" => "2023-01-01T00:00:00"
                   },
                   "id" => to_string(fourth_keyword_id),
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => third_keyword_id,
                     "inserted_at" => "2023-01-01T00:00:00",
                     "status" => "new",
                     "title" => "third keyword",
                     "updated_at" => "2023-01-01T00:00:00"
                   },
                   "id" => to_string(third_keyword_id),
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => second_keyword_id,
                     "inserted_at" => "2023-01-01T00:00:00",
                     "status" => "new",
                     "title" => "second keyword",
                     "updated_at" => "2023-01-01T00:00:00"
                   },
                   "id" => to_string(second_keyword_id),
                   "relationships" => %{},
                   "type" => "keywords"
                 },
                 %{
                   "attributes" => %{
                     "id" => first_keyword_id,
                     "inserted_at" => "2023-01-01T00:00:00",
                     "status" => "new",
                     "title" => "first keyword",
                     "updated_at" => "2023-01-01T00:00:00"
                   },
                   "id" => to_string(first_keyword_id),
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             }
    end
  end

  describe "POST create/2" do
    @tag :register_and_log_in_user_with_token
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

    @tag :register_and_log_in_user_with_token
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

    @tag :register_and_log_in_user_with_token
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

    @tag :register_and_log_in_user_with_token
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

    test "given an unauthenticated user, returns 401 status", %{conn: conn} do
      conn = post(conn, Routes.api_v1_keyword_path(conn, :create))

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "code" => "unauthenticated",
                   "detail" => "Unauthenticated"
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
