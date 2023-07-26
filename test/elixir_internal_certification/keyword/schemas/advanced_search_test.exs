defmodule ElixirInternalCertification.Account.Schemas.AdvancedSearchTest do
  use ElixirInternalCertification.DataCase

  alias Ecto.ULID

  alias ElixirInternalCertification.Keyword.Schemas.AdvancedSearch

  describe "new/1" do
    test "given valid params, returns a valid changeset" do
      expect(ULID, :generate, fn -> "01GQ45DK0QQEWQY6J01HV3BWQW" end)

      assert AdvancedSearch.new(%{
               "search_query" => "nimblehq.co",
               "search_query_type" => "partial_match",
               "search_query_target" => "all",
               "number_of_occurrences" => 0,
               "symbol_notation" => ">"
             }) == %AdvancedSearch{
               id: "01GQ45DK0QQEWQY6J01HV3BWQW",
               search_query: "nimblehq.co",
               search_query_type: "partial_match",
               search_query_target: "all",
               number_of_occurrences: 0,
               symbol_notation: ">"
             }
    end

    test "given MISSING params, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        AdvancedSearch.new(nil)
      end
    end
  end
end
