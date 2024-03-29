defmodule ElixirInternalCertificationWorker.GoogleTest do
  use ElixirInternalCertification.DataCase, async: false

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  @max_attempts 4

  describe "perform/1" do
    test "given a keyword ID and the job is success, returns the keyword lookup and changes the status to completed" do
      use_cassette "google/keyword_with_no_adwords", match_requests_on: [:query] do
        %Keyword{id: keyword_id} = keyword = insert(:keyword, title: "google")

        {:ok, %KeywordLookup{keyword_id: updated_keyword_lookup_keyword_id}} =
          perform_job(GoogleWorker, %{"keyword_id" => keyword_id})

        %Keyword{status: updated_keyword_status} = Repo.reload(keyword)

        assert updated_keyword_lookup_keyword_id == keyword_id
        assert updated_keyword_status == :completed
      end
    end

    test "given a keyword ID and the job is failed, returns the error and keeps the status as pending" do
      use_cassette "google/keyword_with_no_adwords", match_requests_on: [:query] do
        expect(GoogleFetcher, :search, fn _search_query -> {:error, :timeout} end)

        %Keyword{id: keyword_id} = keyword = insert(:keyword, title: "google")

        {:error, :timeout} = perform_job(GoogleWorker, %{"keyword_id" => keyword_id})

        %Keyword{status: updated_keyword_status} = Repo.reload(keyword)

        assert updated_keyword_status == :pending
      end
    end

    test "given max attempts reached, returns {:error, message} and changes the status to failed" do
      use_cassette "google/keyword_with_no_adwords", match_requests_on: [:query] do
        %Keyword{id: keyword_id} = keyword = insert(:keyword, title: "google")

        {:error, message} =
          perform_job(GoogleWorker, %{"keyword_id" => keyword_id}, attempt: @max_attempts)

        assert message == "Failed to look up the keyword ID: #{keyword_id}"

        %Keyword{status: updated_keyword_status} = Repo.reload(keyword)

        assert updated_keyword_status == :failed
      end
    end

    test "given EMPTY keyword ID, raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        perform_job(GoogleWorker, %{"keyword_id" => nil})
      end
    end
  end
end
