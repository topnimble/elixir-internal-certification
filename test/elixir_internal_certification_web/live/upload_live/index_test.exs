defmodule ElixirInternalCertificationWeb.UploadLive.IndexTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import ElixirInternalCertificationWeb.Gettext
  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  @max_keywords_per_upload Application.compile_env!(
                             :elixir_internal_certification,
                             :max_keywords_per_upload
                           )

  describe "LIVE /" do
    @tag :register_and_log_in_user
    test "given a valid submission of a CSV file containing keywords, uploads the keywords and redirects to the keyword page",
         %{
           conn: conn,
           user: user
         } do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert_redirected(
        view,
        Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index)
      )

      keywords = Keywords.list_keywords(user)

      assert length(keywords) == 3

      assert equal?(Enum.map(keywords, fn %Keyword{title: keyword_title} -> keyword_title end), [
               "first keyword",
               "second keyword",
               "third keyword"
             ]) == true

      Enum.map(keywords, fn %Keyword{id: keyword_id} ->
        assert_enqueued(worker: GoogleWorker, args: %{"keyword_id" => keyword_id})
      end)
    end

    @tag :register_and_log_in_user
    test "given a cancellation of a CSV file containing keywords, does NOT upload the keywords", %{
      conn: conn,
      user: user
    } do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    @tag :register_and_log_in_user
    test "given INVALID file extension, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    @tag :register_and_log_in_user
    test "given too large file, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    @tag :register_and_log_in_user
    test "given more than 1 file, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    @tag :register_and_log_in_user
    test "given a file with more than 1,000 keywords, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert result =~
               dgettext(
                 "errors",
                 "You have selected file with more than %{max_keywords_per_upload} keywords",
                 max_keywords_per_upload: @max_keywords_per_upload
               )

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    @tag :register_and_log_in_user
    test "given a file with INVALID data, displays the error", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

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

      assert Keywords.list_keywords(user) == []

      refute_enqueued(worker: GoogleWorker)
    end

    test "given an unauthenticated user, redirects to the log in page", %{conn: conn} do
      assert

      live(conn, Routes.upload_index_path(ElixirInternalCertificationWeb.Endpoint, :index)) ==
        {:error,
         {:redirect,
          %{flash: %{"error" => "You must log in to access this page."}, to: "/users/log_in"}}}
    end
  end
end
