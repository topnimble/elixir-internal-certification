defmodule ElixirInternalCertificationWeb.KeywordLive.ShowTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  setup [:register_and_log_in_user]

  describe "LIVE /keywords/:id" do
    test "shows the keyword of current user", %{conn: conn, user: user} do
      %Keyword{id: keyword_id} =
        keyword = insert(:keyword, user: user, title: "current user keyword")

      insert(:keyword_lookup, keyword: keyword)

      {:ok, _view, html} =
        live(
          conn,
          Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id)
        )

      assert html =~ "current user keyword"
    end

    test "does NOT show the keyword of another user", %{conn: conn, user: _user} do
      another_user = insert(:user)

      %Keyword{id: keyword_id} =
        keyword = insert(:keyword, user: another_user, title: "another user keyword")

      insert(:keyword_lookup, keyword: keyword)

      assert_raise Ecto.NoResultsError, fn ->
        live(
          conn,
          Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id)
        )
      end
    end
  end
end
