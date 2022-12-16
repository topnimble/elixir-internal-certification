defmodule ElixirInternalCertification.Google.ClientTest do
  use ExUnit.Case, async: true

  import Tesla.Mock

  alias ElixirInternalCertification.Google.Client, as: GoogleClient

  setup do
    mock(fn
      %{method: :get, url: "https://google.com/search"} ->
        %Tesla.Env{
          status: 200,
          body:
            ~S(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>)
        }
    end)

    :ok
  end

  describe "search/1" do
    test "given a search query, returns the search results" do
      assert {:ok, %Tesla.Env{} = env} = GoogleClient.search("nimble")
      assert env.status == 200

      assert env.body ==
               ~S(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>)
    end
  end
end
