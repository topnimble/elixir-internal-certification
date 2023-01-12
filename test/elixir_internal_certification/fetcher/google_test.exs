defmodule ElixirInternalCertification.Fetcher.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient
  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher

  describe "search/1" do
    test "given a search query and the server returns OK, returns {:ok, status_code, headers, body}" do
      use_cassette "google/keyword_with_no_adwords", match_requests_on: [:query] do
        assert {:ok, status_code, _headers, body} = GoogleFetcher.search("google")
        assert status_code == 200
        assert body =~ "google"
      end
    end

    test "given a search query and the server returns bad request, returns {:error, 400}" do
      use_cassette :stub, status_code: 400 do
        assert {:error, status_code} = GoogleFetcher.search("google")
        assert status_code == 400
      end
    end

    test "given a search query and the server returns internal server error, returns {:error, 500}" do
      use_cassette :stub, status_code: 500 do
        assert {:error, status_code} = GoogleFetcher.search("google")
        assert status_code == 500
      end
    end

    test "given a search query and the request is timeout, returns {:error, :timeout}" do
      expect(GoogleClient, :search, fn _search_query -> {:error, :timeout} end)

      assert {:error, :timeout} = GoogleFetcher.search("google")
    end
  end
end
