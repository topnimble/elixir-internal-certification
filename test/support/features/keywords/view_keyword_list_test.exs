defmodule ElixirInternalCertificationWeb.Features.Keywords.ViewKeywordListTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.Browser

  alias ElixirInternalCertification.FeatureHelper

  feature "lists all keywords", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: user, title: "fourth keyword")
    insert(:keyword, user: user, title: "fifth keyword")
    insert(:keyword, user: another_user, title: "another keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("second keyword"))
    |> assert_has(Query.text("third keyword"))
    |> assert_has(Query.text("fourth keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("another keyword"))
  end

  feature "given EMPTY query in the URL params, lists all keywords", %{session: session} do
    user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: user, title: "fourth keyword")
    insert(:keyword, user: user, title: "fifth keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index, query: ""))
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("second keyword"))
    |> assert_has(Query.text("third keyword"))
    |> assert_has(Query.text("fourth keyword"))
    |> assert_has(Query.text("fifth keyword"))
  end

  feature "given a query in the URL params, lists matched keywords", %{session: session} do
    user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: user, title: "fourth keyword")
    insert(:keyword, user: user, title: "fifth keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(
      Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index, query: "fi")
    )
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end

  feature "given a user types in a search box, lists matched keywords", %{session: session} do
    user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: user, title: "fourth keyword")
    insert(:keyword, user: user, title: "fifth keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> find(Query.css(".search-form"), fn form ->
      fill_in(form, Query.text_field("Search..."), with: "fi")
    end)
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end

  feature "given a user submits a search form, lists matched keywords", %{session: session} do
    user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: user, title: "fourth keyword")
    insert(:keyword, user: user, title: "fifth keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> find(Query.css(".search-form"), fn form ->
      form
      |> fill_in(Query.text_field("Search..."), with: "fi")
      |> send_keys([:enter])
    end)
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("fifth keyword"))
    |> refute_has(Query.text("second keyword"))
    |> refute_has(Query.text("third keyword"))
    |> refute_has(Query.text("fourth keyword"))
  end
end
