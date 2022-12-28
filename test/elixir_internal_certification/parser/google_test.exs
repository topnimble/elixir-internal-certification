defmodule ElixirInternalCertification.Parser.GoogleTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Fetcher.Google, as: GoogleFetcher
  alias ElixirInternalCertification.Parser.Google, as: GoogleParser

  describe "parse_lookup_result/1" do
    test "given a search result HTML of the `google` query keyword with NO AdWords, returns parsed result" do
      use_cassette "google/keyword_with_no_adwords", match_requests_on: [:query] do
        {:ok, _status_code, _headers, body} = GoogleFetcher.search("google")
        result = GoogleParser.parse_lookup_result(body)

        assert result.html == body
        assert result.number_of_adwords_advertisers == 0
        assert result.number_of_adwords_advertisers_top_position == 0

        assert result.urls_of_adwords_advertisers_top_position == []

        assert result.number_of_non_adwords == 11

        assert result.urls_of_non_adwords == [
                 "https://www.google.co.th/?hl=th",
                 "https://www.google.co.th/maps/@18.3170581,99.3986862,17z?hl=th",
                 "https://translate.google.co.th/?hl=th",
                 "https://trends.google.co.th/trends/?geo=TH",
                 "https://translate.google.co.th/?hl=en&sl=ja&tl=th",
                 "https://www.google.co.th/",
                 "https://www.google.com/intl/th_th/drive/",
                 "https://www.google.com/intl/th_th/chrome/",
                 "https://support.google.com/chrome/community?hl=th",
                 "https://support.google.com/accounts/?hl=th",
                 "https://accounts.google.com/login?hl=th"
               ]

        assert result.number_of_links == 11
      end
    end

    test "given a search result HTML of the `nimble` query keyword with top AdWords, returns parsed result" do
      use_cassette "google/keyword_with_top_adwords", match_requests_on: [:query] do
        {:ok, _status_code, _headers, body} = GoogleFetcher.search("nimble")
        result = GoogleParser.parse_lookup_result(body)

        assert result.html == body
        assert result.number_of_adwords_advertisers == 1
        assert result.number_of_adwords_advertisers_top_position == 1

        assert result.urls_of_adwords_advertisers_top_position == [
                 "https://nimblehq.co/",
                 "https://nimblehq.co/services/e-commerce-development/",
                 "https://nimblehq.co/services/golang-development/",
                 "https://nimblehq.co/services/android-app-development/",
                 "https://nimblehq.co/services/cross-platform-app-development/"
               ]

        assert result.number_of_non_adwords == 14

        assert result.urls_of_non_adwords == [
                 "https://translate.google.com/?um=1&ie=UTF-8&hl=th&client=tw-ob#en/th/nimble",
                 "https://nimblehq.co/",
                 "https://jobs.nimblehq.co/",
                 "https://nimblehq.co/",
                 "https://support.google.com/local-listings?p=how_google_sources",
                 "https://www.nimble.com/",
                 "https://www.facebook.com/TechStarThailand/posts/nimble-thailand-%E0%B8%84%E0%B8%B7%E0%B8%AD-%E0%B8%9A%E0%B8%A3%E0%B8%B4%E0%B8%A9%E0%B8%B1%E0%B8%97%E0%B8%9E%E0%B8%B1%E0%B8%92%E0%B8%99%E0%B8%B2-software-%E0%B9%81%E0%B8%A5%E0%B8%B0%E0%B8%AD%E0%B8%A2%E0%B8%B9%E0%B9%88%E0%B9%80%E0%B8%9A%E0%B8%B7%E0%B9%89%E0%B8%AD%E0%B8%87%E0%B8%AB%E0%B8%A5%E0%B8%B1%E0%B8%87%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1%E0%B8%AA%E0%B8%B3%E0%B9%80%E0%B8%A3%E0%B9%87%E0%B8%88%E0%B8%82%E0%B8%AD%E0%B8%87-startups/1741572129194206/",
                 "https://dict.longdo.com/search/NIMBLE",
                 "https://th.linkedin.com/company/nimblehq",
                 "https://jobs.blognone.com/company/nimble",
                 "https://www.quickserv.co.th/storage/HPE/Artificial-Intelligence-SAN/HPE-Nimble-Storage-HF20H.html",
                 "https://www.gonimble.net/",
                 "https://wmspanel.com/nimble",
                 "https://www.techtalkthai.com/hpe-nimble-storage-for-vmware-by-metro-connect/"
               ]

        assert result.number_of_links == 19
      end
    end

    test "given a search result HTML of the `hosting` query keyword with top and bottom AdWords, returns parsed result" do
      use_cassette "google/keyword_with_top_and_bottom_adwords", match_requests_on: [:query] do
        {:ok, _status_code, _headers, body} = GoogleFetcher.search("hosting")
        result = GoogleParser.parse_lookup_result(body)

        assert result.html == body
        assert result.number_of_adwords_advertisers == 7
        assert result.number_of_adwords_advertisers_top_position == 4

        assert result.urls_of_adwords_advertisers_top_position == [
                 "https://www.top10.com/hosting/comparison",
                 "https://www.top10.com/hosting/wordpresshosting-comparison",
                 "https://hosting.z.com/th/share-hosting/",
                 "https://hosting.z.com/th/share-hosting/",
                 "https://www.hostatom.com/web-hosting/",
                 "https://www.hostatom.com/wordpress-hosting",
                 "https://www.thaidatahosting.com/hosting-solution/",
                 "https://www.thaidatahosting.com/cloud-service/cloud-ssd-hosting/wordpress/"
               ]

        assert result.number_of_non_adwords == 10

        assert result.urls_of_non_adwords == [
                 "https://www.hostinglotus.com/",
                 "https://www.hostinglotus.com/hosting-unlimited-database/",
                 "https://www.pathosting.co.th/hosting/whatis",
                 "https://www.godaddy.com/th-th/hosting/web-hosting",
                 "https://www.hostneverdie.com/",
                 "https://hosting.z.com/th/th/share-hosting/",
                 "https://hosting.z.com/th/th/",
                 "https://www.hostinger.in.th/",
                 "https://netway.co.th/linux-hosting",
                 "https://www.chaiyohosting.com/"
               ]

        assert result.number_of_links == 24
      end
    end
  end
end
