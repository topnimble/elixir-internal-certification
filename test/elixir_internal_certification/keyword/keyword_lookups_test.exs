defmodule ElixirInternalCertification.Keyword.KeywordLookupsTest do
  use ElixirInternalCertification.DataCase

  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  describe "schedule_keyword_lookup/1" do
    test "given a keyword, returns the enqueued job" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword)

      assert {:ok, %Oban.Job{}} = KeywordLookups.schedule_keyword_lookup(keyword)

      assert_enqueued(worker: GoogleWorker, args: %{"keyword_id" => keyword_id})
    end

    test "given EMPTY keyword, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        KeywordLookups.schedule_keyword_lookup(nil)
      end
    end
  end

  describe "create_keyword_lookup/2" do
    test "given valid attributes, returns {:ok, %KeywordLookup{}}" do
      %Keyword{id: keyword_id} = _keyword = insert(:keyword, title: "keyword")

      assert {:ok,
              %KeywordLookup{keyword_id: inserted_keyword_lookup_keyword_id} =
                _inserted_keyword_lookup} =
               KeywordLookups.create_keyword_lookup(%{
                 keyword_id: keyword_id,
                 html:
                   ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>keyword - Google Search</title>...</head>...</html>),
                 number_of_adwords_advertisers: 4,
                 number_of_adwords_advertisers_top_position: 2,
                 urls_of_adwords_advertisers_top_position: ["https://nimblehq.co"],
                 number_of_non_adwords: 10,
                 urls_of_non_adwords: ["https://nimblehq.co"],
                 number_of_links: 20
               })

      assert inserted_keyword_lookup_keyword_id == keyword_id

      assert %Keyword{id: ^keyword_id} = Keywords.get_keyword!(keyword_id)
    end

    test "given EMPTY attributes, returns {:error, %Ecto.Changeset{}}" do
      assert {:error, changeset} = KeywordLookups.create_keyword_lookup(%{})

      assert "can't be blank" in errors_on(changeset).keyword_id
      assert "can't be blank" in errors_on(changeset).html
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).urls_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).number_of_non_adwords
      assert "can't be blank" in errors_on(changeset).urls_of_non_adwords
      assert "can't be blank" in errors_on(changeset).number_of_links
    end

    test "given INVALID attributes, returns {:error, %Ecto.Changeset{}}" do
      assert {:error, changeset} =
               KeywordLookups.create_keyword_lookup(%{
                 keyword_id: %{},
                 html: %{},
                 number_of_adwords_advertisers: %{},
                 number_of_adwords_advertisers_top_position: %{},
                 urls_of_adwords_advertisers_top_position: %{},
                 number_of_non_adwords: %{},
                 urls_of_non_adwords: %{},
                 number_of_links: %{}
               })

      assert "is invalid" in errors_on(changeset).keyword_id
      assert "is invalid" in errors_on(changeset).html
      assert "is invalid" in errors_on(changeset).number_of_adwords_advertisers
      assert "is invalid" in errors_on(changeset).number_of_adwords_advertisers_top_position
      assert "is invalid" in errors_on(changeset).urls_of_adwords_advertisers_top_position
      assert "is invalid" in errors_on(changeset).number_of_non_adwords
      assert "is invalid" in errors_on(changeset).urls_of_non_adwords
      assert "is invalid" in errors_on(changeset).number_of_links
    end

    test "given INVALID keyword ID, returns {:error, %Ecto.Changeset{}}" do
      assert {:error, changeset} =
               KeywordLookups.create_keyword_lookup(%{
                 keyword_id: 999_999,
                 html:
                   ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>),
                 number_of_adwords_advertisers: 4,
                 number_of_adwords_advertisers_top_position: 2,
                 urls_of_adwords_advertisers_top_position: ["https://nimblehq.co"],
                 number_of_non_adwords: 10,
                 urls_of_non_adwords: ["https://nimblehq.co"],
                 number_of_links: 20
               })

      assert "does not exist" in errors_on(changeset).keyword
    end
  end
end
