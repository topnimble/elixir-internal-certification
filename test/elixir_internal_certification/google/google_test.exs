defmodule ElixirInternalCertification.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Google

  describe "search/1" do
    test "given the request is successful with successful response, returns {:ok, response}" do
      use_cassette "google/nimble", match_requests_on: [:query] do
        assert {:ok, %Tesla.Env{} = response} = Google.search("nimble")
        assert response.body =~ "nimble"
        assert response.status == 200
      end
    end
  end
end
