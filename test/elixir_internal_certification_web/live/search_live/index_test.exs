defmodule ElixirInternalCertificationWeb.SearchLive.IndexTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "LIVE /advanced_searches" do
    @tag :register_and_log_in_user
    test "given EMPTY query in the URL params, lists all keywords", %{conn: conn, user: user} do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
            query: "",
            query_type: "partial_match",
            query_target: "all"
          )
        )

      assert html =~ "first keyword"
      assert html =~ "second keyword"
      assert html =~ "third keyword"
      assert html =~ "fourth keyword"
      assert html =~ "fifth keyword"
    end

    @tag :register_and_log_in_user
    test "given a query and partial match type in the URL params, lists matched keywords", %{
      conn: conn,
      user: user
    } do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
            query: "www",
            query_type: "partial_match",
            query_target: "all"
          )
        )

      assert html =~ "first keyword"
      assert html =~ "fifth keyword"
      refute html =~ "second keyword"
      refute html =~ "third keyword"
      refute html =~ "fourth keyword"
    end

    @tag :register_and_log_in_user
    test "given a query and exact match type in the URL params, lists matched keywords", %{
      conn: conn,
      user: user
    } do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
            query: "https://www.phoenixframework.org/",
            query_type: "exact_match",
            query_target: "all"
          )
        )

      assert html =~ "first keyword"
      refute html =~ "second keyword"
      refute html =~ "third keyword"
      refute html =~ "fourth keyword"
      refute html =~ "fifth keyword"
    end

    @tag :register_and_log_in_user
    test "given a query and occurrences type in the URL params, lists matched keywords", %{
      conn: conn,
      user: user
    } do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
            query: "www",
            query_type: "occurrences",
            query_target: "all",
            number_of_occurrences: 0,
            symbol_notation: ">"
          )
        )

      assert html =~ "first keyword"
      assert html =~ "fifth keyword"
      refute html =~ "second keyword"
      refute html =~ "third keyword"
      refute html =~ "fourth keyword"
    end

    @tag :register_and_log_in_user
    test "given NO params, lists NO keywords", %{conn: conn, user: user} do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index)
        )

      refute html =~ "first keyword"
      refute html =~ "second keyword"
      refute html =~ "third keyword"
      refute html =~ "fourth keyword"
      refute html =~ "fifth keyword"
    end

    @tag :register_and_log_in_user
    test "given a changed form, lists matched keywords", %{conn: conn, user: user} do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, view, _html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index)
        )

      search_query = "www"
      search_query_type = "partial_match"
      search_query_target = "all"

      view
      |> form(".search-form", %{
        "search_form" => %{
          "search_query" => search_query,
          "search_query_type" => search_query_type,
          "search_query_target" => search_query_target
        }
      })
      |> render_change()

      assert_patch(view, "/advanced_searches?query=www&query_type=partial_match&query_target=all")

      rendered_view = render(view)

      assert rendered_view =~ "first keyword"
      assert rendered_view =~ "fifth keyword"
      refute rendered_view =~ "second keyword"
      refute rendered_view =~ "third keyword"
      refute rendered_view =~ "fourth keyword"

      search_query = "https://www.phoenixframework.org/"
      search_query_type = "exact_match"
      search_query_target = "all"

      view
      |> form(".search-form", %{
        "search_form" => %{
          "search_query" => search_query,
          "search_query_type" => search_query_type,
          "search_query_target" => search_query_target
        }
      })
      |> render_change()

      assert_patch(
        view,
        "/advanced_searches?query=https%3A%2F%2Fwww.phoenixframework.org%2F&query_type=exact_match&query_target=all"
      )

      rendered_view = render(view)

      assert rendered_view =~ "first keyword"
      refute rendered_view =~ "second keyword"
      refute rendered_view =~ "third keyword"
      refute rendered_view =~ "fourth keyword"
      refute rendered_view =~ "fifth keyword"

      search_query = "www"
      search_query_type = "occurrences"
      search_query_target = "all"

      view
      |> form(".search-form", %{
        "search_form" => %{
          "search_query" => search_query,
          "search_query_type" => search_query_type,
          "search_query_target" => search_query_target
        }
      })
      |> render_change()

      assert_patch(
        view,
        "/advanced_searches?query=www&query_type=occurrences&query_target=all&number_of_occurrences=0&symbol_notation=%3E"
      )

      rendered_view = render(view)

      assert rendered_view =~ "first keyword"
      assert rendered_view =~ "fifth keyword"
      refute rendered_view =~ "second keyword"
      refute rendered_view =~ "third keyword"
      refute rendered_view =~ "fourth keyword"
    end

    @tag :register_and_log_in_user
    test "given a submitted form, lists matched keywords", %{conn: conn, user: user} do
      first_keyword = insert(:keyword, user: user, title: "first keyword")

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://www.phoenixframework.org/"]
      )

      second_keyword = insert(:keyword, user: user, title: "second keyword")
      insert(:keyword_lookup, keyword: second_keyword)
      third_keyword = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword_lookup, keyword: third_keyword)
      fourth_keyword = insert(:keyword, user: user, title: "fourth keyword")
      insert(:keyword_lookup, keyword: fourth_keyword)
      fifth_keyword = insert(:keyword, user: user, title: "fifth keyword")

      insert(:keyword_lookup,
        keyword: fifth_keyword,
        urls_of_non_adwords: ["https://www.phoenixframework.org/blog"]
      )

      {:ok, view, _html} =
        live(
          conn,
          Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index)
        )

      search_query = "www"
      search_query_type = "partial_match"
      search_query_target = "all"

      {:ok, view_2, _html_2} =
        view
        |> form(".search-form", %{
          "search_form" => %{
            "search_query" => search_query,
            "search_query_type" => search_query_type,
            "search_query_target" => search_query_target
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert_redirected(
        view,
        "/advanced_searches?query=www&query_type=partial_match&query_target=all"
      )

      rendered_view_2 = render(view_2)

      assert rendered_view_2 =~ "first keyword"
      assert rendered_view_2 =~ "fifth keyword"
      refute rendered_view_2 =~ "second keyword"
      refute rendered_view_2 =~ "third keyword"
      refute rendered_view_2 =~ "fourth keyword"

      search_query = "https://www.phoenixframework.org/"
      search_query_type = "exact_match"
      search_query_target = "all"

      {:ok, view_3, _html_3} =
        view_2
        |> form(".search-form", %{
          "search_form" => %{
            "search_query" => search_query,
            "search_query_type" => search_query_type,
            "search_query_target" => search_query_target
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert_redirected(
        view_2,
        "/advanced_searches?query=https%3A%2F%2Fwww.phoenixframework.org%2F&query_type=exact_match&query_target=all"
      )

      rendered_view_3 = render(view_3)

      assert rendered_view_3 =~ "first keyword"
      refute rendered_view_3 =~ "second keyword"
      refute rendered_view_3 =~ "third keyword"
      refute rendered_view_3 =~ "fourth keyword"
      refute rendered_view_3 =~ "fifth keyword"

      search_query = "www"
      search_query_type = "occurrences"
      search_query_target = "all"

      {:ok, view_4, _html_4} =
        view_3
        |> form(".search-form", %{
          "search_form" => %{
            "search_query" => search_query,
            "search_query_type" => search_query_type,
            "search_query_target" => search_query_target
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert_redirected(
        view_3,
        "/advanced_searches?query=www&query_type=occurrences&query_target=all&number_of_occurrences=0&symbol_notation=%3E"
      )

      rendered_view_4 = render(view_4)

      assert rendered_view_4 =~ "first keyword"
      assert rendered_view_4 =~ "fifth keyword"
      refute rendered_view_4 =~ "second keyword"
      refute rendered_view_4 =~ "third keyword"
      refute rendered_view_4 =~ "fourth keyword"
    end

    test "given an unauthenticated user, redirects to the log in page", %{conn: conn} do
      assert live(
               conn,
               Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index)
             ) ==
               {:error,
                {:redirect,
                 %{flash: %{"error" => "You must log in to access this page."}, to: "/users/log_in"}}}
    end
  end
end
