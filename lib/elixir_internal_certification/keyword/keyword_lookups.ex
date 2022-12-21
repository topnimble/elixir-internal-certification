defmodule ElixirInternalCertification.Keyword.KeywordLookups do
  @moduledoc """
  The Keyword Lookups context.
  """
  use Oban.Worker, queue: :scheduled, max_attempts: 10

  import Ecto.Query, warn: false

  alias ElixirInternalCertification.Google
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.KeywordLookup
  alias ElixirInternalCertification.Repo

  @impl true
  def perform(%{args: %{"keyword_id" => keyword_id}}) do
    keyword = Keywords.get_keyword!(keyword_id)
    look_up(keyword)
  end

  def look_up(keyword_id) do
    keyword = Keywords.get_keyword!(keyword_id)
    response_body = get_search_results(keyword)
    response_body = filter_out_invalid_characters(response_body)
    parsed_lookup_result = parse_lookup_result(response_body)
    data_to_insert = parsed_lookup_result |> Map.put(:title, keyword.title)
    create_keyword_lookup(data_to_insert)
  end

  def parse_lookup_result(raw_html) do
    {:ok, html} = Floki.parse_document(raw_html)

    number_of_adwords_advertisers =
      html
      |> Floki.find("[data-text-ad=1]")
      |> length()

    number_of_adwords_advertisers_top_position =
      html
      |> Floki.find("#tads")
      |> Floki.find("[data-text-ad=1]")
      |> length()

    urls_of_adwords_advertisers_top_position =
      html
      |> Floki.find("#tads")
      |> Floki.find("[data-text-ad=1]")
      |> Floki.find("a[href][data-ved]:first-child")
      |> Floki.attribute("a", "href")

    urls_of_non_adwords =
      html
      |> Floki.find("#res")
      |> Floki.find("a[href][data-ved][data-usg]:first-child")
      |> Floki.attribute("a", "href")

    number_of_non_adwords = length(urls_of_non_adwords)

    urls_of_adwords_advertisers_bottom_position =
      html
      |> Floki.find("#bottomads")
      |> Floki.find("[data-text-ad=1]")
      |> Floki.find("a[href][data-ved]:first-child")
      |> Floki.attribute("a", "href")

    link_urls = urls_of_adwords_advertisers_top_position ++ urls_of_non_adwords ++ urls_of_adwords_advertisers_bottom_position
    number_of_links = length(link_urls)

    %{
      html: raw_html,
      number_of_adwords_advertisers: number_of_adwords_advertisers,
      number_of_adwords_advertisers_top_position: number_of_adwords_advertisers_top_position,
      urls_of_adwords_advertisers_top_position: urls_of_adwords_advertisers_top_position,
      number_of_non_adwords: number_of_non_adwords,
      urls_of_non_adwords: urls_of_non_adwords,
      number_of_links: number_of_links
    }
  end

  def create_keyword_lookup(attrs \\ %{}) do
    %KeywordLookup{}
    |> KeywordLookup.changeset(attrs)
    |> Repo.insert()
  end

  defp get_search_results(query) do
    {:ok, %Tesla.Env{body: body}} = Google.search(query)
    body
  end

  defp filter_out_invalid_characters(string) do
    if String.valid?(string) do
      string
    else
      string
      |> String.chunk(:printable)
      |> Enum.filter(&String.printable?/1)
      |> Enum.join()
    end
  end
end
