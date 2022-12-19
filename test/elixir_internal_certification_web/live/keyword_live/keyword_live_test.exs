defmodule ElixirInternalCertificationWeb.KeywordLiveTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  setup [:register_and_log_in_user]

  describe "LIVE /keywords" do
    test "lists all keywords", %{conn: conn, user: user} do
      another_user = insert(:user)
      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: another_user, title: "another keyword")

      {:ok, _view, html} =
        live(conn, Routes.keyword_path(ElixirInternalCertificationWeb.Endpoint, :index))

      assert html =~ "first keyword"
      assert html =~ "second keyword"
      assert html =~ "third keyword"
      refute html =~ "another keyword"
    end
  end
end
