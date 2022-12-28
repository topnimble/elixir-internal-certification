defmodule ElixirInternalCertification.Fetcher.Client.GoogleTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  use Mimic

  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient

  describe "search/1" do
    test "given a search query and the server returns OK, returns the response with 200 status code and search results" do
      use_cassette :stub,
        url: "https://google.com/search?q=nimble",
        body:
          ~S(<html itemscope="" itemtype="http://schema.org/SearchResultsPage" lang="en"><head><title>nimble - Google Search</title>...</head>...</html>) do
        assert {:ok, %Tesla.Env{status: status_code, body: body} = _response} =
                 GoogleClient.search("nimble")

        assert status_code == 200
        assert body =~ "nimble"
      end
    end

    test "given a search query and the server returns bad request, returns the response with 400 status code" do
      use_cassette :stub, status_code: 400 do
        assert {:ok, %Tesla.Env{status: status_code} = _response} = GoogleClient.search("nimble")
        assert status_code == 400
      end
    end

    test "given a search query and the server returns internal server error, returns the response with 500 status code" do
      use_cassette :stub, status_code: 500 do
        assert {:ok, %Tesla.Env{status: status_code} = _response} = GoogleClient.search("nimble")
        assert status_code == 500
      end
    end

    test "given a search query and the request is timeout, returns {:error, :timeout}" do
      expect(GoogleClient, :search, fn _query -> {:error, :timeout} end)

      assert {:error, :timeout} = GoogleClient.search("nimble")
    end
  end
end
