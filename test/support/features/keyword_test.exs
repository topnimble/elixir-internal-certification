defmodule ElixirInternalCertificationWeb.Features.KeywordTest do
  use ElixirInternalCertificationWeb.FeatureCase, async: false

  import Wallaby.Browser

  alias ElixirInternalCertification.FeatureHelper

  feature "lists all keywords", %{session: session} do
    user = insert(:user)
    another_user = insert(:user)
    insert(:keyword, user: user, title: "first keyword")
    insert(:keyword, user: user, title: "second keyword")
    insert(:keyword, user: user, title: "third keyword")
    insert(:keyword, user: another_user, title: "another keyword")

    session
    |> FeatureHelper.authenticated_user(user)
    |> visit(Routes.keyword_path(ElixirInternalCertificationWeb.Endpoint, :index))
    |> assert_has(Query.text("first keyword"))
    |> assert_has(Query.text("second keyword"))
    |> assert_has(Query.text("third keyword"))
    |> refute_has(Query.text("another keyword"))
  end
end
