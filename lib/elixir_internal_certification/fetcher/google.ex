defmodule ElixirInternalCertification.Fetcher.Google do
  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient

  def search(query), do: GoogleClient.search(query)
end
