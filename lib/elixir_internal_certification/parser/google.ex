defmodule ElixirInternalCertification.Parser.Google do
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

    link_urls =
      urls_of_adwords_advertisers_top_position ++
        urls_of_non_adwords ++ urls_of_adwords_advertisers_bottom_position

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
end
