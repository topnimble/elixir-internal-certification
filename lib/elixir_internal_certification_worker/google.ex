defmodule ElixirInternalCertificationWorker.Google do
  use Oban.Worker, max_attempts: 4

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher
  alias ElixirInternalCertification.Keyword.{KeywordLookups, Keywords}
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Parser.Google, as: GoogleParser

  @max_attempts 4

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}, attempt: @max_attempts} = _oban_job) do
    keyword = Keywords.get_keyword!(keyword_id)

    keyword
    |> Keywords.update_status!(:failed)
    |> Keywords.broadcast_keyword_update()

    {:error, "Failed to look up the keyword ID: #{keyword_id}"}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}} = _oban_job) do
    keyword = Keywords.get_keyword!(keyword_id)

    keyword
    |> Keywords.update_status!(:pending)
    |> Keywords.broadcast_keyword_update()

    result = execute(keyword)

    case result do
      {:ok, _} ->
        keyword
        |> Keywords.update_status!(:completed)
        |> Keywords.broadcast_keyword_update()

        result

      error ->
        error
    end
  end

  defp execute(%Keyword{id: keyword_id, title: keyword_title} = _keyword) do
    with {:ok, _status_code, _headers, body} <- GoogleFetcher.search(keyword_title),
         params <-
           body
           |> GoogleParser.parse_lookup_result()
           |> Map.put(:keyword_id, keyword_id) do
      KeywordLookups.create_keyword_lookup(params)
    end
  end
end
