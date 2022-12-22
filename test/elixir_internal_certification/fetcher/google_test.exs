defmodule ElixirInternalCertification.Fetcher.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher

  describe "search/1" do
    test "given the request is successful with successful response, returns {:ok, response}" do
      use_cassette "google/nimble", match_requests_on: [:query] do
        assert {:ok, %Tesla.Env{} = response} = GoogleFetcher.search("nimble")
        assert response.body =~ "nimble"
        assert response.status == 200
      end
    end
  end
end
