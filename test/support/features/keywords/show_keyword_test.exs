defmodule ElixirInternalCertificationWeb.Features.Keywords.ShowKeywordTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.Browser

  alias ElixirInternalCertification.FeatureHelper
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  feature "shows the keyword of current user", %{session: session} do
    user = insert(:user)
    %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user, title: "current user keyword")
    insert(:keyword_lookup, keyword: keyword)

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id))
    |> assert_has(Query.text("current user keyword"))
  end

  feature "do NOT show the keyword of another user", %{session: session} do
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
