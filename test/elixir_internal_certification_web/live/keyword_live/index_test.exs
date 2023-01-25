defmodule ElixirInternalCertificationWeb.KeywordLive.IndexTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Keywords

  describe "LIVE /keywords" do
    @tag :register_and_log_in_user
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

    @tag :register_and_log_in_user
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

    @tag :register_and_log_in_user
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

    @tag :register_and_log_in_user
    test "given a changed form, lists matched keywords", %{conn: conn, user: user} do
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword, user: user, title: "fifth keyword")

      {:ok, view, _html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      search_query = "fi"

      view
      |> form(".search-form", %{"search_form" => %{"search_query" => search_query}})
      |> render_change()

      assert_patch(view, "/?query=fi")

      rendered_view = render(view)

      assert rendered_view =~ "first keyword"
      assert rendered_view =~ "fifth keyword"
      refute rendered_view =~ "second keyword"
      refute rendered_view =~ "third keyword"
      refute rendered_view =~ "fourth keyword"

      view
      |> form(".search-form", %{"search_form" => %{"search_query" => ""}})
      |> render_change()

      assert_patch(view, "/")
    end

    @tag :register_and_log_in_user
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
        |> form(".search-form", %{"search_form" => %{"search_query" => search_query}})
        |> render_submit()
        |> follow_redirect(conn)

      assert_redirected(view, "/?query=fi")

      rendered_view_2 = render(view_2)

      assert rendered_view_2 =~ "first keyword"
      assert rendered_view_2 =~ "fifth keyword"
      refute rendered_view_2 =~ "second keyword"
      refute rendered_view_2 =~ "third keyword"
      refute rendered_view_2 =~ "fourth keyword"

      view_2
      |> form(".search-form", %{"search_form" => %{"search_query" => ""}})
      |> render_submit()

      assert_redirect(view_2, "/")
    end

    test "given an unauthenticated user, redirects to the log in page", %{conn: conn} do
      assert live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index)) ==
               {:error,
                {:redirect,
                 %{flash: %{"error" => "You must log in to access this page."}, to: "/users/log_in"}}}
    end
  end

  describe "handle_info/2" do
    @tag :register_and_log_in_user
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
