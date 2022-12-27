defmodule ElixirInternalCertification.Fetcher.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher

  describe "search/1" do
    test "given the request is successful with successful response, returns {:ok, response}" do
      use_cassette "google/nimble", match_requests_on: [:query] do
        assert {:ok, status_code, _headers, body} = GoogleFetcher.search("nimble")
        assert status_code == 200
        assert body =~ "nimble"
      end
    end
  end
end
