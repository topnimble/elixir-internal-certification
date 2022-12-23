defmodule ElixirInternalCertificationWorker.Google do
  use Oban.Worker, max_attempts: 10

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher
  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Parser.Google, as: GoogleParser

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}} = _oban_job), do: execute(keyword_id)

  def execute(keyword_id) do
    %Keyword{id: keyword_id, title: keyword_title} = _keyword = Keywords.get_keyword!(keyword_id)

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
