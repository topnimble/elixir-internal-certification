defmodule ElixirInternalCertification.Keyword.KeywordLookups do
  @moduledoc """
  The Keyword Lookups context.
  """
  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Repo
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}
  alias ElixirInternalCertificationWorker.Google, as: GoogleWorker

  @average_number_of_seconds_between_each_lookup 60

  def schedule_keyword_lookup(%Keyword{id: keyword_id} = _keyword) do
    number_of_seconds = randomize_number_of_seconds_based_on_pending_jobs()

    %{"keyword_id" => keyword_id}
    |> GoogleWorker.new(schedule_in: number_of_seconds)
    |> Oban.insert()
  end

  def create_keyword_lookup(attrs \\ %{}) do
    %KeywordLookup{}
    |> KeywordLookup.changeset(attrs)
    |> Repo.insert()
  end

  defp randomize_number_of_seconds_based_on_pending_jobs do
    number_of_pending_oban_jobs =
      Oban
      |> Oban.config()
      |> Oban.Repo.aggregate(
        where(Oban.Job, [o], o.state in ["available", "scheduled", "executing"]),
        :count
      )

    min_seconds = @average_number_of_seconds_between_each_lookup * number_of_pending_oban_jobs
    max_seconds = min_seconds + @average_number_of_seconds_between_each_lookup
    Enum.random(min_seconds..max_seconds)
  end
end
