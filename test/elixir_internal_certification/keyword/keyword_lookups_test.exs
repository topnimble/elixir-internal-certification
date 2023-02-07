defmodule ElixirInternalCertification.Keyword.KeywordLookupsTest do
  use ElixirInternalCertification.DataCase

  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertification.Keyword.Schemas.{AdvancedSearch, Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  describe "get_number_of_url_results/2" do
    setup do
      user = insert(:user)
      first_keyword = insert(:keyword, user: user)

      insert(:keyword_lookup,
        keyword: first_keyword,
        urls_of_adwords_advertisers_top_position: ["https://elixir-lang.org/"],
        urls_of_non_adwords: [
          "https://elixir-lang.org/",
          "https://elixir-lang.org/getting-started/introduction.html",
          "https://elixirforum.com/",
          "https://www.phoenixframework.org/",
          "https://www.phoenixframework.org/blog"
        ]
      )

      second_keyword = insert(:keyword, user: user)

      insert(:keyword_lookup,
        keyword: second_keyword,
        urls_of_adwords_advertisers_top_position: [
          "https://elixir-lang.org/",
          "https://elixir-lang.org/getting-started/introduction.html",
          "https://www.phoenixframework.org/"
        ],
        urls_of_non_adwords: ["https://elixir-lang.org/", "https://elixir-lang.org/"]
      )

      %{user: user}
    end

    test "given a `elixir` search query with partial match type and all target, returns 8", %{
      user: user
    } do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "partial_match",
        search_query_target: "all"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 8
    end

    test "given a `elixir` search query with partial match type and URLs of AdWords advertisers top position target, returns 3",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "partial_match",
        search_query_target: "urls_of_adwords_advertisers_top_position"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `elixir` search query with partial match type and URLs of non AdWords target, returns 5",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "partial_match",
        search_query_target: "urls_of_non_adwords"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 5
    end

    test "given a `elixir` search query with exact match type and all target, returns 0", %{
      user: user
    } do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "exact_match",
        search_query_target: "all"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 0
    end

    test "given a `elixir` search query with exact match type and URLs of AdWords advertisers top position target, returns 0",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "exact_match",
        search_query_target: "urls_of_adwords_advertisers_top_position"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 0
    end

    test "given a `elixir` search query with exact match type and URLs of non AdWords target, returns 0",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "elixir",
        search_query_type: "exact_match",
        search_query_target: "urls_of_non_adwords"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 0
    end

    test "given a `https://elixir-lang.org/` search query with exact match type and all target, returns 5",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "https://elixir-lang.org/",
        search_query_type: "exact_match",
        search_query_target: "all"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 5
    end

    test "given a `https://elixir-lang.org/` search query with exact match type and URLs of AdWords advertisers top position target, returns 2",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "https://elixir-lang.org/",
        search_query_type: "exact_match",
        search_query_target: "urls_of_adwords_advertisers_top_position"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given a `https://elixir-lang.org/` search query with exact match type and URLs of non AdWords target, returns 3",
         %{user: user} do
      advanced_search_params = %AdvancedSearch{
        search_query: "https://elixir-lang.org/",
        search_query_type: "exact_match",
        search_query_target: "urls_of_non_adwords"
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, all target, `>` symbol notation and 0 number of occurences, returns 3",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "all",
        symbol_notation: ">",
        number_of_occurrences: 0
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, all target, `>=` symbol notation and 1 number of occurences, returns 3",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "all",
        symbol_notation: ">=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, all target, `<` symbol notation and 2 number of occurences, returns 3",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "all",
        symbol_notation: "<",
        number_of_occurrences: 2
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, all target, `<=` symbol notation and 1 number of occurences, returns 3",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "all",
        symbol_notation: "<=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, all target, `=` symbol notation and 1 number of occurences, returns 3",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "all",
        symbol_notation: "=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 3
    end

    test "given a `www` search query with occurrences type, URLs of AdWords advertisers top position target, `>` symbol notation and 0 number of occurences, returns 1",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_adwords_advertisers_top_position",
        symbol_notation: ">",
        number_of_occurrences: 0
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 1
    end

    test "given a `www` search query with occurrences type, URLs of AdWords advertisers top position target, `>=` symbol notation and 1 number of occurences, returns 1",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_adwords_advertisers_top_position",
        symbol_notation: ">=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 1
    end

    test "given a `www` search query with occurrences type, URLs of AdWords advertisers top position target, `<` symbol notation and 2 number of occurences, returns 1",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_adwords_advertisers_top_position",
        symbol_notation: "<",
        number_of_occurrences: 2
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 1
    end

    test "given a `www` search query with occurrences type, URLs of AdWords advertisers top position target, `<=` symbol notation and 1 number of occurences, returns 1",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_adwords_advertisers_top_position",
        symbol_notation: "<=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 1
    end

    test "given a `www` search query with occurrences type, URLs of AdWords advertisers top position target, `=` symbol notation and 1 number of occurences, returns 1",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_adwords_advertisers_top_position",
        symbol_notation: "=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 1
    end

    test "given a `www` search query with occurrences type, URLs of non AdWords target, `>` symbol notation and 0 number of occurences, returns 2",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_non_adwords",
        symbol_notation: ">",
        number_of_occurrences: 0
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given a `www` search query with occurrences type, URLs of non AdWords target, `>=` symbol notation and 1 number of occurences, returns 2",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_non_adwords",
        symbol_notation: ">=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given a `www` search query with occurrences type, URLs of non AdWords target, `<` symbol notation and 2 number of occurences, returns 2",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_non_adwords",
        symbol_notation: "<",
        number_of_occurrences: 2
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given a `www` search query with occurrences type, URLs of non AdWords target, `<=` symbol notation and 1 number of occurences, returns 2",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_non_adwords",
        symbol_notation: "<=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given a `www` search query with occurrences type, URLs of non AdWords target, `=` symbol notation and 1 number of occurences, returns 2",
         %{
           user: user
         } do
      advanced_search_params = %AdvancedSearch{
        search_query: "www",
        search_query_type: "occurrences",
        search_query_target: "urls_of_non_adwords",
        symbol_notation: "=",
        number_of_occurrences: 1
      }

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 2
    end

    test "given NO advanced search params, returns 11", %{user: user} do
      advanced_search_params = nil

      assert KeywordLookups.get_number_of_url_results(user, advanced_search_params) == 11
    end
  end

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
      invalid_keyword_params = params_for(:keyword_lookup, keyword_id: -1)

      assert {:error, changeset} = KeywordLookups.create_keyword_lookup(invalid_keyword_params)

      assert "does not exist" in errors_on(changeset).keyword
    end
  end
end
