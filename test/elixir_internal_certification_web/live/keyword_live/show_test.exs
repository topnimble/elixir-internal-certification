defmodule ElixirInternalCertificationWeb.KeywordLive.ShowTest do
  use ElixirInternalCertificationWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  setup [:register_and_log_in_user]

  describe "LIVE /keywords/:id" do
    test "shows the keyword of current user", %{conn: conn, user: user} do
      %Keyword{id: keyword_id} =
        keyword = insert(:keyword, user: user, title: "current user keyword")

      insert(:keyword_lookup,
        keyword: keyword,
        number_of_adwords_advertisers: 6,
        number_of_adwords_advertisers_top_position: 5,
        number_of_non_adwords: 16,
        urls_of_adwords_advertisers_top_position: ["https://nimblehq.co/"],
        urls_of_non_adwords: ["https://www.google.com/"]
      )

      {:ok, _view, html} =
        live(
          conn,
          Routes.keyword_show_path(ElixirInternalCertificationWeb.Endpoint, :show, keyword_id)
        )

      assert html =~ "current user keyword"
      assert html =~ "https://nimblehq.co/"
      assert html =~ "https://www.google.com/"

      parsed_html = Floki.parse_document!(html)

      assert Floki.find(parsed_html, ".number-of-adwords-advertisers") == [
               {"div", [{"class", "display-1 number-of-adwords-advertisers"}], ["\n6\n        "]}
             ]

      assert Floki.find(parsed_html, ".number-of-adwords-advertisers-top-position") == [
               {"div", [{"class", "display-1 number-of-adwords-advertisers-top-position"}],
                ["\n5\n        "]}
             ]

      assert Floki.find(parsed_html, ".number-of-non-adwords") == [
               {"div", [{"class", "display-1 number-of-non-adwords"}], ["\n16\n        "]}
             ]
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
