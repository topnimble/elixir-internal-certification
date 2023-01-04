defmodule ElixirInternalCertification.Fetcher.Google do
  alias ElixirInternalCertification.Fetcher.Client.Google, as: GoogleClient

  def search(query) do
    case GoogleClient.search(query) do
      {:ok, %Tesla.Env{status: status_code, headers: headers, body: body}}
      when status_code in 200..299 ->
        {:ok, status_code, headers, body}

      {:ok, %Tesla.Env{status: status_code}} ->
        {:error, status_code}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
