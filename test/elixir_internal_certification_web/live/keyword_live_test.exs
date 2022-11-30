defmodule ElixirInternalCertificationWeb.KeywordLiveTest do
  use ElixirInternalCertificationWeb.ConnCase

  import Phoenix.LiveViewTest
  import ElixirInternalCertification.KeywordsFixtures

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  defp create_keyword(_) do
    keyword = keyword_fixture()
    %{keyword: keyword}
  end

  describe "Index" do
    setup [:create_keyword]

    test "lists all keywords", %{conn: conn, keyword: keyword} do
      {:ok, _index_live, html} = live(conn, Routes.keyword_index_path(conn, :index))

      assert html =~ "Listing Keywords"
      assert html =~ keyword.title
    end

    test "saves new keyword", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.keyword_index_path(conn, :index))

      assert index_live |> element("a", "New Keyword") |> render_click() =~
               "New Keyword"

      assert_patch(index_live, Routes.keyword_index_path(conn, :new))

      assert index_live
             |> form("#keyword-form", keyword: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#keyword-form", keyword: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.keyword_index_path(conn, :index))

      assert html =~ "Keyword created successfully"
      assert html =~ "some title"
    end

    test "updates keyword in listing", %{conn: conn, keyword: keyword} do
      {:ok, index_live, _html} = live(conn, Routes.keyword_index_path(conn, :index))

      assert index_live |> element("#keyword-#{keyword.id} a", "Edit") |> render_click() =~
               "Edit Keyword"

      assert_patch(index_live, Routes.keyword_index_path(conn, :edit, keyword))

      assert index_live
             |> form("#keyword-form", keyword: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#keyword-form", keyword: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.keyword_index_path(conn, :index))

      assert html =~ "Keyword updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes keyword in listing", %{conn: conn, keyword: keyword} do
      {:ok, index_live, _html} = live(conn, Routes.keyword_index_path(conn, :index))

      assert index_live |> element("#keyword-#{keyword.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#keyword-#{keyword.id}")
    end
  end

  describe "Show" do
    setup [:create_keyword]

    test "displays keyword", %{conn: conn, keyword: keyword} do
      {:ok, _show_live, html} = live(conn, Routes.keyword_show_path(conn, :show, keyword))

      assert html =~ "Show Keyword"
      assert html =~ keyword.title
    end

    test "updates keyword within modal", %{conn: conn, keyword: keyword} do
      {:ok, show_live, _html} = live(conn, Routes.keyword_show_path(conn, :show, keyword))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Keyword"

      assert_patch(show_live, Routes.keyword_show_path(conn, :edit, keyword))

      assert show_live
             |> form("#keyword-form", keyword: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#keyword-form", keyword: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.keyword_show_path(conn, :show, keyword))

      assert html =~ "Keyword updated successfully"
      assert html =~ "some updated title"
    end
  end
end
