defmodule ElixirInternalCertification.Fetcher.Google do
  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient

  def search(query) do
    case GoogleClient.search(query) do
      {:ok, %Tesla.Env{status: status_code, headers: headers, body: body}} -> {:ok, status_code, headers, body}
      {:error, reason} -> {:error, reason}
    end
  end
end
