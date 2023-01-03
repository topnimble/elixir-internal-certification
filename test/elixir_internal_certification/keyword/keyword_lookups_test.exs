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
      %Keyword{id: keyword_id} = keyword = insert(:keyword, title: "keyword")
      valid_keyword_params = params_for(:keyword_lookup, keyword: keyword)

      assert {:ok, %KeywordLookup{} = inserted_keyword_lookup} =
               KeywordLookups.create_keyword_lookup(valid_keyword_params)

      assert inserted_keyword_lookup.keyword_id == keyword_id
      assert inserted_keyword_lookup.html == valid_keyword_params.html

      assert inserted_keyword_lookup.number_of_adwords_advertisers ==
               valid_keyword_params.number_of_adwords_advertisers

      assert inserted_keyword_lookup.number_of_adwords_advertisers_top_position ==
               valid_keyword_params.number_of_adwords_advertisers_top_position

      assert inserted_keyword_lookup.urls_of_adwords_advertisers_top_position ==
               valid_keyword_params.urls_of_adwords_advertisers_top_position

      assert inserted_keyword_lookup.number_of_non_adwords ==
               valid_keyword_params.number_of_non_adwords

      assert inserted_keyword_lookup.urls_of_non_adwords == valid_keyword_params.urls_of_non_adwords
      assert inserted_keyword_lookup.number_of_links == valid_keyword_params.number_of_links

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

    test "given a NON-existing keyword ID, returns {:error, %Ecto.Changeset{}}" do
      invalid_keyword_params = params_for(:keyword_lookup, keyword_id: 999_999)

      assert {:error, changeset} = KeywordLookups.create_keyword_lookup(invalid_keyword_params)

      assert "does not exist" in errors_on(changeset).keyword
    end
  end
end
