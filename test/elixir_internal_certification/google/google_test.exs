defmodule ElixirInternalCertification.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Google

  describe "search/1" do
    test "given the request is successful with successful response, returns {:ok, response}" do
      use_cassette "google/search_results", match_requests_on: [:query] do
        assert {:ok, %Tesla.Env{} = env} = Google.search("nimble")
        assert env.status == 200
        assert env.body =~ "nimble"
      end
    end
  end
end
