defmodule ElixirInternalCertificationWorker.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true
  use Oban.Testing, repo: ElixirInternalCertification.Repo

  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  describe "perform/1" do
    test "given a keyword ID, returns the keyword lookup" do
      use_cassette "google/nimble", match_requests_on: [:query] do
        %Keyword{id: keyword_id} = _keyword = insert(:keyword, title: "nimble")

        {:ok, keyword_lookup} = perform_job(GoogleWorker, %{"keyword_id" => keyword_id})

        assert keyword_lookup.keyword_id == keyword_id
      end
    end

    test "given EMPTY keyword ID, raises ArgumentError" do
      use_cassette "google/nimble", match_requests_on: [:query] do
        assert_raise ArgumentError, fn ->
          perform_job(GoogleWorker, %{"keyword_id" => nil})
        end
      end
    end
  end
end
