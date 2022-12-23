defmodule ElixirInternalCertification.Keyword.KeywordsTest do
  use ElixirInternalCertification.DataCase

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  @fixture_path "test/support/fixtures"

  describe "list_keywords/1" do
    test "given a user, returns a list of keywords belongs to the user sorted by ID in descending order" do
      user = insert(:user)
      another_user = insert(:user)

      %Keyword{id: first_keyword_id} = insert(:keyword, user: user, title: "first keyword")
      %Keyword{id: second_keyword_id} = insert(:keyword, user: user, title: "second keyword")
      %Keyword{id: third_keyword_id} = insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: another_user, title: "another keyword")

      keywords = Keywords.list_keywords(user)

      assert length(keywords) == 3

      assert Enum.map(keywords, fn keyword -> keyword.id end) == [
               third_keyword_id,
               second_keyword_id,
               first_keyword_id
             ]
    end

    test "given a user with NO keywords, returns an empty list" do
      user = insert(:user)
      another_user = insert(:user)

      insert(:keyword, user: another_user, title: "another keyword")

      assert Keywords.list_keywords(user) == []
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.list_keywords(user)
      end
    end
  end

  describe "create_keywords/2" do
    @valid_attrs ["first keyword", "second keyword", "third keyword"]
    @valid_and_empty_attrs ["first keyword", ""]
    @invalid_attrs [
      %{title: "first invalid keyword"},
      %{title: "second invalid keyword"},
      %{title: "third invalid keyword"}
    ]

    test "given valid attributes, returns a number of keywords and a list of results" do
      %User{id: user_id} = user = insert(:user)

      {number_of_keywords, records} = Keywords.create_keywords(user, @valid_attrs)

      assert number_of_keywords == 3

      assert equal?(Enum.map(records, fn record -> record.title end), [
               "first keyword",
               "second keyword",
               "third keyword"
             ]) == true

      keywords = Keywords.list_keywords(user)

      assert length(keywords) == 3

      assert equal?(Enum.map(keywords, fn keyword -> keyword.title end), [
               "first keyword",
               "second keyword",
               "third keyword"
             ]) == true

      assert Enum.map(keywords, fn keyword -> assert keyword.user_id == user_id end)
    end

    test "given valid and empty attributes, returns :error" do
      user = insert(:user)

      assert Keywords.create_keywords(user, @valid_and_empty_attrs) == :error

      assert Keywords.list_keywords(user) == []
    end

    test "given INVALID attributes, returns :error" do
      user = insert(:user)

      assert Keywords.create_keywords(user, @invalid_attrs) == :error

      assert Keywords.list_keywords(user) == []
    end

    test "given INVALID attribute type, raises FunctionClauseError" do
      user = insert(:user)

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keywords(user, "invalid attribute type")
      end

      assert Keywords.list_keywords(user) == []
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keywords(user, @valid_attrs)
      end
    end
  end

  describe "parse_csv!/1" do
    test "given an existing file path with keywords, returns :ok with a list of keywords" do
      path = Path.join([@fixture_path, "/assets/keywords.csv"])

      assert {:ok, keywords} = Keywords.parse_csv!(path)

      assert equal?(keywords, ["first keyword", "second keyword", "third keyword"]) == true
    end

    test "given an existing file path with NO keywords, returns :ok with an empty list of keywords" do
      path = Path.join([@fixture_path, "/assets/empty.csv"])

      assert {:ok, []} = Keywords.parse_csv!(path)
    end

    test "given an existing file path with too many keywords, returns {:error, :too_many_keywords}" do
      path = Path.join([@fixture_path, "/assets/keywords.csv"])

      expect(Keywords, :parse_csv!, fn _ -> {:error, :too_many_keywords} end)

      assert Keywords.parse_csv!(path) == {:error, :too_many_keywords}
    end

    test "given the path is nil, raises FunctionClauseError" do
      path = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.parse_csv!(path)
      end
    end

    test "given a path which file does NOT exist, raises File.Error" do
      path = Path.join([@fixture_path, "/assets/non_existence_file.csv"])

      assert_raise File.Error, fn ->
        Keywords.parse_csv!(path)
      end
    end
  end

  describe "get_keyword!/1" do
    test "given a valid keyword ID, returns the keyword" do
      %Keyword{id: keyword_id} = insert(:keyword)

      keyword = Keywords.get_keyword!(keyword_id)

      assert keyword.id == keyword_id
    end

    test "given empty keyword ID, raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Keywords.get_keyword!(nil)
      end
    end
  end
end
