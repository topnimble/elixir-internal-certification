defmodule ElixirInternalCertificationWeb.Features.Keywords.SearchKeywordListTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.Browser

  alias ElixirInternalCertification.FeatureHelper

  feature "given EMPTY query in the URL params, lists all keywords", %{session: session} do
    user = insert(:user)

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

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(
      Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
        query: "",
        query_type: "partial_match",
        query_target: "all"
      )
    )
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("second keyword"))
    |> assert_has(Query.text("third keyword"))
    |> assert_has(Query.text("fourth keyword"))
    |> assert_has(Query.text("fifth keyword"))
  end

  feature "given a query and partial match type in the URL params, lists matched keywords", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)

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

    another_user_keyword = insert(:keyword, user: another_user, title: "another keyword")
    insert(:keyword_lookup, keyword: another_user_keyword)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(
      Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
        query: "www",
        query_type: "partial_match",
        query_target: "all"
      )
    )
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end

  feature "given a query and exact match type in the URL params, lists matched keywords", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)

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

    another_user_keyword = insert(:keyword, user: another_user, title: "another keyword")
    insert(:keyword_lookup, keyword: another_user_keyword)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(
      Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
        query: "https://www.phoenixframework.org/",
        query_type: "exact_match",
        query_target: "all"
      )
    )
    |> assert_has(Query.text("first keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
    |> refute_has(Query.text("fifth keyword"))
  end

  feature "given a query and occurrences type in the URL params, lists matched keywords", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)

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

    another_user_keyword = insert(:keyword, user: another_user, title: "another keyword")
    insert(:keyword_lookup, keyword: another_user_keyword)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(
      Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index,
        query: "www",
        query_type: "occurrences",
        query_target: "all",
        number_of_occurrences: 0,
        symbol_notation: ">"
      )
    )
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end

  feature "given NO params, lists NO keywords", %{session: session} do
    user = insert(:user)

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

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> refute_has(Query.text("first keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
    |> refute_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("another keyword"))
  end

  feature "given a user types in a search box, lists matched keywords", %{session: session} do
    user = insert(:user)

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

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> find(Query.css(".search-form"), fn form ->
      fill_in(form, Query.text_field("string"), with: "www")
    end)
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end

  feature "given a user submits a search form, lists matched keywords", %{session: session} do
    user = insert(:user)

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

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.advanced_search_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> find(Query.css(".search-form"), fn form ->
      form
      |> fill_in(Query.text_field("string"), with: "www")
      |> send_keys([:enter])
    end)
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end
end
