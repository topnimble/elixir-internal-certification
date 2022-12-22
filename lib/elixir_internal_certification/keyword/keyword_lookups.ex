defmodule ElixirInternalCertification.Keyword.KeywordLookups do
  @moduledoc """
  The Keyword Lookups context.
  """
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Repo
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  @average_seconds_between_each_lookup 60 * 3

  def schedule_keyword_lookup(%Keyword{id: keyword_id} = _keyword) do
    query = from o in "oban_jobs", where: o.state in ["available", "scheduled", "executing"]
    number_of_pending_oban_jobs = Repo.aggregate(query, :count)

    # Randomize number of seconds based on number of pending Oban jobs
    min_seconds = @average_seconds_between_each_lookup * number_of_pending_oban_jobs
    max_seconds = min_seconds + @average_seconds_between_each_lookup
    number_of_seconds = Enum.random(min_seconds..max_seconds)

    %{"keyword_id" => keyword_id}
    |> GoogleWorker.new(schedule_in: number_of_seconds)
    |> Oban.insert()
  end

  def create_keyword_lookup(attrs \\ %{}) do
    %KeywordLookup{}
    |> KeywordLookup.changeset(attrs)
    |> Repo.insert()
  end
end
