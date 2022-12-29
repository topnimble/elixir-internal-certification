defmodule ElixirInternalCertification.Keyword.Schemas.KeywordLookupTest do
  use ElixirInternalCertification.DataCase

  alias Ecto.Changeset
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}

  describe "changeset/2" do
    test "given valid params, returns a valid changeset" do
      %Keyword{id: keyword_id} = _keyword = insert(:keyword, title: "keyword")

      changeset =
        KeywordLookup.changeset(%{
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

      assert %Changeset{
               valid?: true,
               changes: %{
                 keyword_id: ^keyword_id,
                 html:
                   ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>keyword - Google Search</title>...</head>...</html>),
                 number_of_adwords_advertisers: 4,
                 number_of_adwords_advertisers_top_position: 2,
                 urls_of_adwords_advertisers_top_position: ["https://nimblehq.co"],
                 number_of_non_adwords: 10,
                 urls_of_non_adwords: ["https://nimblehq.co"],
                 number_of_links: 20
               }
             } = changeset
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

    test "given INVALID keyword ID, returns :error with an INVALID changeset" do
      assert {:error, changeset} =
               %{
                 keyword_id: 999_999,
                 html:
                   ~s(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>keyword - Google Search</title>...</head>...</html>),
                 number_of_adwords_advertisers: 4,
                 number_of_adwords_advertisers_top_position: 2,
                 urls_of_adwords_advertisers_top_position: ["https://nimblehq.co"],
                 number_of_non_adwords: 10,
                 urls_of_non_adwords: ["https://nimblehq.co"],
                 number_of_links: 20
               }
               |> KeywordLookup.changeset()
               |> Repo.insert()

      assert "does not exist" in errors_on(changeset).keyword
    end
  end
end
