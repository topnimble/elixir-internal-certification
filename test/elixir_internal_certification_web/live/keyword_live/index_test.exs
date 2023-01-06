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
      insert(:keyword, user: another_user, title: "another keyword")

      {:ok, _view, html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      assert html =~ "first keyword"
      assert html =~ "second keyword"
      assert html =~ "third keyword"
      refute html =~ "another keyword"
    end
  end

  describe "handle_info/2" do
    test "given the {:updated, %Keyword{}}, updates the keyword list", %{conn: conn, user: user} do
      keyword = insert(:keyword, user: user, status: :pending)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      {:ok, %Phoenix.LiveViewTest.View{pid: pid} = view, html} =
        live(conn, Routes.keyword_index_path(ElixirInternalCertificationWeb.Endpoint, :index))

      assert html =~ "Pending"
      assert render(view) =~ "Pending"

      updated_keyword = Keywords.update_status!(keyword, :completed)
      send(pid, {:updated, updated_keyword})

      assert render(view) =~ "Completed"
    end
  end
end
