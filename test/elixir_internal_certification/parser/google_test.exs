defmodule ElixirInternalCertification.Parser.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.GoogleHelper
  alias ElixirInternalCertification.Parser.Google, as: GoogleParser

  describe "parse_lookup_result/1" do
    test "given a search result HTML of the `nimble` query, returns parsed result" do
      html = GoogleHelper.get_html_of_search_results("nimble")
      result = GoogleParser.parse_lookup_result(html)

      assert result.html == html
      assert result.number_of_adwords_advertisers == 1
      assert result.number_of_adwords_advertisers_top_position == 1

      assert result.urls_of_adwords_advertisers_top_position == [
               "https://nimblehq.co/",
               "https://nimblehq.co/services/android-app-development/",
               "https://nimblehq.co/services/e-commerce-development/",
               "https://nimblehq.co/services/cross-platform-app-development/",
               "https://nimblehq.co/services/golang-development/"
             ]

      assert result.number_of_non_adwords == 14

      assert result.urls_of_non_adwords == [
               "https://translate.google.com/?um=1&ie=UTF-8&hl=th&client=tw-ob#en/th/nimble",
               "https://nimblehq.co/",
               "https://nimblehq.co/locations/bangkok/",
               "https://nimblehq.co/",
               "https://support.google.com/local-listings?p=how_google_sources",
               "https://www.nimble.com/",
               "https://www.facebook.com/TechStarThailand/posts/nimble-thailand-%E0%B8%84%E0%B8%B7%E0%B8%AD-%E0%B8%9A%E0%B8%A3%E0%B8%B4%E0%B8%A9%E0%B8%B1%E0%B8%97%E0%B8%9E%E0%B8%B1%E0%B8%92%E0%B8%99%E0%B8%B2-software-%E0%B9%81%E0%B8%A5%E0%B8%B0%E0%B8%AD%E0%B8%A2%E0%B8%B9%E0%B9%88%E0%B9%80%E0%B8%9A%E0%B8%B7%E0%B9%89%E0%B8%AD%E0%B8%87%E0%B8%AB%E0%B8%A5%E0%B8%B1%E0%B8%87%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1%E0%B8%AA%E0%B8%B3%E0%B9%80%E0%B8%A3%E0%B9%87%E0%B8%88%E0%B8%82%E0%B8%AD%E0%B8%87-startups/1741572129194206/",
               "https://dict.longdo.com/search/NIMBLE",
               "https://th.linkedin.com/company/nimblehq?trk=public_jobs_jserp-result_job-search-card-subtitle",
               "https://jobs.blognone.com/company/nimble",
               "https://www.quickserv.co.th/storage/HPE/Artificial-Intelligence-SAN/HPE-Nimble-Storage-HF20H.html",
               "https://www.gonimble.net/",
               "https://wmspanel.com/nimble",
               "https://www.techtalkthai.com/hpe-nimble-storage-all-flash-storage-introduction/"
             ]

      assert result.number_of_links == 19
    end
  end
end
