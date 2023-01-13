defmodule ElixirInternalCertificationWeb.KeywordLive.IndexTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Keywords

  setup [:register_and_log_in_user]

  describe "LIVE /keywords" do
    test "lists all keywords", %{conn: conn, user: user} do
      another_user = insert(:user)
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")
      insert(:keyword, user: another_user, title: "another keyword")

      {:ok, _view, html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      assert html =~ "first keyword"
      assert html =~ "second keyword"
      assert html =~ "third keyword"
      assert html =~ "fourth keyword"
      assert html =~ "fifth keyword"
      refute html =~ "another keyword"
    end

    test "given EMPTY search query in the URL params, lists all keywords", %{conn: conn, user: user} do
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")

      {:ok, _view, html} =
        live(
          conn,
          Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index, query: "")
        )

      assert html =~ "first keyword"
      assert html =~ "second keyword"
      assert html =~ "third keyword"
      assert html =~ "fourth keyword"
      assert html =~ "fifth keyword"
    end

    test "given a search query in the URL params, lists matched keywords", %{conn: conn, user: user} do
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")

      {:ok, _view, html} =
        live(
          conn,
          Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index, query: "fi")
        )

      assert html =~ "first keyword"
      assert html =~ "fifth keyword"
      refute html =~ "second keyword"
      refute html =~ "third keyword"
      refute html =~ "fourth keyword"
    end

    test "given a changed form, lists matched keywords", %{conn: conn, user: user} do
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")

      {:ok, view, _html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      search_query = "fi"

      render_change(view, :change_search_query, %{"search_box" => %{"search_query" => search_query}})

      assert_patch(view, "/?query=fi")

      rendered_view = render(view)

      assert rendered_view =~ "first keyword"
      assert rendered_view =~ "fifth keyword"
      refute rendered_view =~ "second keyword"
      refute rendered_view =~ "third keyword"
      refute rendered_view =~ "fourth keyword"

      render_change(view, :change_search_query, %{"search_box" => %{"search_query" => ""}})

      assert_patch(view, "/")
    end

    test "given a submitted form, lists matched keywords", %{conn: conn, user: user} do
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")

      {:ok, view, _html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      search_query = "fi"

      {:ok, view_2, _html_2} =
        view
        |> render_submit(:submit_search_query, %{"search_box" => %{"search_query" => search_query}})
        |> follow_redirect(conn)

      assert_redirected(view, "/?query=fi")

      rendered_view_2 = render(view_2)

      assert rendered_view_2 =~ "first keyword"
      assert rendered_view_2 =~ "fifth keyword"
      refute rendered_view_2 =~ "second keyword"
      refute rendered_view_2 =~ "third keyword"
      refute rendered_view_2 =~ "fourth keyword"

      render_submit(view_2, :submit_search_query, %{"search_box" => %{"search_query" => ""}})

      assert_redirect(view_2, "/")
    end
  end

  describe "handle_info/2" do
    test "given the {:updated, %Keyword{}}, updates the keyword list", %{conn: conn, user: user} do
      keyword = insert(:keyword, user: user, status: :pending)

      {:ok, %Phoenix.LiveViewTest.View{pid: pid} = view, html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      assert html =~ "Pending"
      refute html =~ "Completed"

      rendered_view = render(view)

      assert rendered_view =~ "Pending"
      refute rendered_view =~ "Completed"

      updated_keyword = Keywords.update_status!(keyword, :completed)
      send(pid, {:updated, updated_keyword})

      rendered_view_after_update = render(view)

      assert rendered_view_after_update =~ "Completed"
      refute rendered_view_after_update =~ "Pending"
    end
  end
end
