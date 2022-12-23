defmodule ElixirInternalCertificationWorker.Google do
  use Oban.Worker, max_attempts: 4

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher
  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Parser.Google, as: GoogleParser

  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}} = _oban_job, attempt: 4) do
    keyword = Keywords.get_keyword!(keyword_id)
    Keywords.update_status(keyword, :failed)
    {:error, "Failed to look up the keyword ID: #{keyword_id}"}
  end

  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}} = _oban_job) do
    keyword = Keywords.get_keyword!(keyword_id)
    result = execute(keyword)
    Keywords.update_status(keyword, :completed)
    result
  end

  def execute(%Keyword{} = keyword) do
    %Keyword{id: keyword_id, title: keyword_title} = keyword

    keyword_title
    |> get_html_of_search_results()
    |> GoogleParser.parse_lookup_result()
    |> Map.put(:keyword_id, keyword_id)
    |> KeywordLookups.create_keyword_lookup()
  end

  defp get_html_of_search_results(query) do
    {:ok, %Tesla.Env{body: body}} = GoogleFetcher.search(query)
    body
  end
end
