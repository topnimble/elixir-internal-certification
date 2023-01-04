defmodule ElixirInternalCertification.Keyword.Schemas.KeywordLookupTest do
  use ElixirInternalCertification.DataCase

  alias Ecto.Changeset
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}

  describe "changeset/2" do
    test "given valid params, returns a valid changeset" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword, title: "keyword")
      valid_keyword_params = params_for(:keyword_lookup, keyword: keyword)

      %Changeset{changes: changes} = changeset = KeywordLookup.changeset(valid_keyword_params)

      assert changeset.valid? == true
      assert changes.keyword_id == keyword_id
      assert changes.html == valid_keyword_params.html

      assert changes.number_of_adwords_advertisers ==
               valid_keyword_params.number_of_adwords_advertisers

      assert changes.number_of_adwords_advertisers_top_position ==
               valid_keyword_params.number_of_adwords_advertisers_top_position

      assert changes.urls_of_adwords_advertisers_top_position ==
               valid_keyword_params.urls_of_adwords_advertisers_top_position

      assert changes.number_of_non_adwords == valid_keyword_params.number_of_non_adwords
      assert changes.urls_of_non_adwords == valid_keyword_params.urls_of_non_adwords
      assert changes.number_of_links == valid_keyword_params.number_of_links
    end

    test "given EMPTY params, returns an INVALID changeset" do
      assert changeset = KeywordLookup.changeset(%{})

      assert "can't be blank" in errors_on(changeset).keyword_id
      assert "can't be blank" in errors_on(changeset).html
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers
      assert "can't be blank" in errors_on(changeset).number_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).urls_of_adwords_advertisers_top_position
      assert "can't be blank" in errors_on(changeset).number_of_non_adwords
      assert "can't be blank" in errors_on(changeset).urls_of_non_adwords
      assert "can't be blank" in errors_on(changeset).number_of_links
    end

    test "givan INVALID params, returns an INVALID changeset" do
      assert changeset =
               KeywordLookup.changeset(%{
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

      assert {:error, changeset} =
               invalid_keyword_params
               |> KeywordLookup.changeset()
               |> Repo.insert()

      assert "does not exist" in errors_on(changeset).keyword
    end
  end
end
