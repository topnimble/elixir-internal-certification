defmodule ElixirInternalCertification.Fetcher.Client.GoogleTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient

  describe "search/1" do
    test "given a search query, returns the search results" do
      use_cassette :stub,
        url: "https://google.com/search?q=nimble",
        body:
          ~S(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>) do
        assert {:ok, %Tesla.Env{} = response} = GoogleClient.search("nimble")
        assert response.body =~ "nimble"
        assert response.status == 200
      end
    end
  end
end
