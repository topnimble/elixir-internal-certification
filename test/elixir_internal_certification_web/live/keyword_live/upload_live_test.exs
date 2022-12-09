defmodule ElixirInternalCertificationWeb.UploadLiveTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Keywords

  setup [:register_and_log_in_user]

  describe "LIVE /" do
    test "uploads valid CSV file and submits", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
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

    test "uploads valid CSV file and cancels", %{conn: conn, user: user} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
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

    test "uploads INVALID file extension", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "invalid_file_extension.txt",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
            type: "text/plain"
          }
        ])

      render_upload(keyword, "invalid_file_extension.txt")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ "You have selected an unacceptable file type"
    end

    test "uploads too large file", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
            size: 999_999_999_999_999,
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ "Too large"
    end

    test "uploads more than 1 file", %{conn: conn} do
      {:ok, view, _html} =
        live(conn, Routes.upload_path(ElixirInternalCertificationWeb.Endpoint, :index))

      keyword =
        file_input(view, "#upload-form", :keyword, [
          %{
            name: "keywords.csv",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          },
          %{
            name: "keywords_2.csv",
            content: "keyword\nfirst keyword\nsecond keyword\nthird keyword",
            type: "text/csv"
          }
        ])

      render_upload(keyword, "keywords.csv")
      render_upload(keyword, "keywords_2.csv")

      result =
        view
        |> element("#upload-form")
        |> render_change()

      assert result =~ "You have selected too many files"
    end
  end
end
