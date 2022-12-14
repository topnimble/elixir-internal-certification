defmodule ElixirInternalCertificationWeb.UploadLiveTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext
  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Keywords

  setup [:register_and_log_in_user]

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  describe "LIVE /" do
    test "given a valid CSV file containing keywords and submits, uploads the keywords", %{
      conn: conn,
      user: user
    } do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "first keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ "100%"

      view
      |> element("#upload-form")
      |> render_submit()

      assert_redirected(view, Routes.keyword_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keywords = Keywords.list_keywords(user)

      assert length(keywords) == 3

      assert MapSet.equal?(
               MapSet.new(Enum.map(keywords, fn keyword -> keyword.title end)),
               MapSet.new(["first keyword", "second keyword", "third keyword"])
             ) == true
    end

    test "given a valid CSV file containing keywords and cancels, does NOT upload the keywords", %{
      conn: conn,
      user: user
    } do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "first keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          }
        ])

      %{"ref" => ref} = List.first(keyword.entries)

      render_upload(keyword, "keywords.csv")

      view
      |> element(".remove-file-button")
      |> render_click(%{"ref" => ref})

      result =
        view
        |> element("#upload-form")
        |> render_change()

      refute result =~ "keywords.csv"

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given INVALID file extension, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "invalid_file_extension.txt",
            content: "first keyword\nsecond keyword\nthird keyword",
            type: "text/plain"
          }
        ])

      render_upload(keyword, "invalid_file_extension.txt")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ dgettext("errors", "You have selected an unacceptable file type")

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given too large file, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "first keyword\nsecond keyword\nthird keyword",
            size: 999_999_999_999_999,
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ dgettext("errors", "Too large")

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given more than 1 file, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "first keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          },
          %{
            name: "keywords_2.csv",
            content: "first keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")
      render_upload(keyword, "keywords_2.csv")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ dgettext("errors", "You have selected too many files")

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given a file with more than 1,000 keywords, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      generated_content =
        Enum.map_join(1..(@max_keywords_per_upload + 1), "\n", fn _i ->
          Faker.Lorem.word()
        end)

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: generated_content,
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")

      result =
        view
        |> element("#upload-form")
        |> render_submit()

      assert result =~ dgettext("errors", "You have selected file with more than 1000 keywords")

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given a file with INVALID data, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: " \n \n ",
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")

      result =
        view
        |> element("#upload-form")
        |> render_submit()

      assert result =~ dgettext("errors", "You have selected file with invalid data")

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end
  end
end
