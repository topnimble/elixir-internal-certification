defmodule ElixirInternalCertification.Google do
  alias ElixirInternalCertification.Google.Client, as: GoogleClient

  def search(query), do: GoogleClient.search(query)
end
