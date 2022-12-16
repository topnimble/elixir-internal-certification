defmodule ElixirInternalCertification.Google.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://google.com"

  plug Tesla.Middleware.Headers, [
    {"Accept-Language", "en-US,en;q=0.7,en;q=0.3"},
    {"Content-Language", "en-US"},
    {"User-Agent",
     "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"}
  ]

  plug Tesla.Middleware.FollowRedirects

  def search(keyword), do: get("/search", query: [q: keyword])
end
