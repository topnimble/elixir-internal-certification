defmodule ElixirInternalCertification.Keyword.KeywordLookupsTest do
  use ElixirInternalCertification.DataCase
  use Oban.Testing, repo: ElixirInternalCertification.Repo

  alias ElixirInternalCertification.Keyword.KeywordLookups
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  describe "schedule_keyword_lookup/1" do
    test "given a keyword, returns the enqueued job" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword)

      KeywordLookups.schedule_keyword_lookup(keyword)

      assert_enqueued worker: GoogleWorker, args: %{"keyword_id" => keyword_id}
    end
  end

  describe "create_keyword_lookup/2" do
    @invalid_attrs %{
      keyword_id: nil,
      html: nil,
      number_of_adwords_advertisers: nil,
      number_of_adwords_advertisers_top_position: nil,
      urls_of_adwords_advertisers_top_position: nil,
      number_of_non_adwords: nil,
      urls_of_non_adwords: nil,
      number_of_links: nil
    }
    @invalid_keyword_id_attrs %{
      keyword_id: 999_999,
      html:
        ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>),
      number_of_adwords_advertisers: 4,
      number_of_adwords_advertisers_top_position: 2,
      urls_of_adwords_advertisers_top_position: [],
      number_of_non_adwords: 10,
      urls_of_non_adwords: [],
      number_of_links: 20
    }

    test "given valid attributes, returns {:ok, %KeywordLookup{}}" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword)

      assert {:ok, %KeywordLookup{} = keyword_lookup} =
               KeywordLookups.create_keyword_lookup(valid_attrs(keyword))

      assert keyword_lookup.keyword_id == keyword_id
    end

    test "given INVALID attributes, returns {:error, %Ecto.Changeset{}}" do
      assert {:error, changeset} = KeywordLookups.create_keyword_lookup(@invalid_attrs)

      assert "can't be blank" in errors_on(changeset).keyword_id
      assert "can't be blank" in errors_on(changeset).html
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).urls_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).number_of_non_adwords
      assert "can't be blank" in errors_on(changeset).urls_of_non_adwords
      assert "can't be blank" in errors_on(changeset).number_of_links
    end

    test "given INVALID keyword ID, returns {:error, %Ecto.Changeset{}}" do
      assert {:error, changeset} = KeywordLookups.create_keyword_lookup(@invalid_keyword_id_attrs)

      assert "does not exist" in errors_on(changeset).keyword
    end

    defp valid_attrs(%Keyword{id: keyword_id, title: keyword_title} = _keyword) do
      %{
        keyword_id: keyword_id,
        html:
          ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>#{keyword_title} - Google Search</title>...</head>...</html>),
        number_of_adwords_advertisers: 4,
        number_of_adwords_advertisers_top_position: 2,
        urls_of_adwords_advertisers_top_position: [],
        number_of_non_adwords: 10,
        urls_of_non_adwords: [],
        number_of_links: 20
      }
    end
  end
end
