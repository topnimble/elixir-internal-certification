defmodule ElixirInternalCertificationWeb.Features.Keywords.ShowKeywordTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.Browser

  alias ElixirInternalCertification.FeatureHelper
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  feature "shows the keyword of current user", %{session: session} do
    user = insert(:user)
    %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user, title: "current user keyword")

    insert(:keyword_lookup,
      keyword: keyword,
      number_of_adwords_advertisers: 6,
      number_of_adwords_advertisers_top_position: 5,
      number_of_non_adwords: 16
    )

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id))
    |> assert_has(Query.text("current user keyword"))
    |> assert_has(Query.css(".number-of-adwords-advertisers", text: "6"))
    |> assert_has(Query.css(".number-of-adwords-advertisers-top-position", text: "5"))
    |> assert_has(Query.css(".number-of-non-adwords", text: "16"))
  end

  feature "does NOT show the keyword of another user", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)

    %Keyword{id: keyword_id} =
      keyword = insert(:keyword, user: another_user, title: "another user keyword")

    insert(:keyword_lookup, keyword: keyword)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id))
    |> refute_has(Query.text("another user keyword"))
  end
end
