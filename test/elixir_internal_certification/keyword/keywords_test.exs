defmodule ElixirInternalCertification.Keyword.KeywordsTest do
  use ElixirInternalCertification.DataCase

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.{Keyword, KeywordLookup}

  @fixture_path "test/support/fixtures"

  describe "list_keywords/1" do
    test "given a user, returns a list of keywords belongs to the user sorted by ID in descending order" do
      user = insert(:user)
      another_user = insert(:user)

      %Keyword{id: first_keyword_id} =
        first_keyword = insert(:keyword, user: user, title: "first keyword")

      _first_keyword_lookup = insert(:keyword_lookup, keyword: first_keyword)

      %Keyword{id: second_keyword_id} =
        second_keyword = insert(:keyword, user: user, title: "second keyword")

      _second_keyword_lookup = insert(:keyword_lookup, keyword: second_keyword)

      %Keyword{id: third_keyword_id} =
        third_keyword = insert(:keyword, user: user, title: "third keyword")

      _third_keyword_lookup = insert(:keyword_lookup, keyword: third_keyword)

      another_keyword = insert(:keyword, user: another_user, title: "another keyword")
      _another_keyword_lookup = insert(:keyword_lookup, keyword: another_keyword)

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
    test "given valid attributes, returns a number of keywords and a list of results" do
      %User{id: user_id} = user = insert(:user)

      {:ok, {number_of_keywords, records}} =
        Keywords.create_keywords(user, ["first keyword", "second keyword", "third keyword"])

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

      assert Enum.map(keywords, fn %Keyword{user_id: keyword_user_id} ->
               assert keyword_user_id == user_id
             end)
    end

    test "given a list of keywords containing an EMPTY value, returns {:error, :invalid_data}" do
      user = insert(:user)

      assert Keywords.create_keywords(user, ["first keyword", "second keyword", ""]) ==
               {:error, :invalid_data}

      assert Keywords.list_keywords(user) == []
    end

    test "given a list of keywords containing an INVALID value, returns {:error, :invalid_data}" do
      user = insert(:user)

      assert Keywords.create_keywords(user, [
               "first keyword",
               "second keyword",
               %{}
             ]) == {:error, :invalid_data}

      assert Keywords.list_keywords(user) == []
    end

    test "given EMPTY attributes, raises FunctionClauseError" do
      user = insert(:user)

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keywords(user, nil)
      end

      assert Keywords.list_keywords(user) == []
    end

    test "given INVALID attributes, raises FunctionClauseError" do
      user = insert(:user)

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keywords(user, "invalid attribute")
      end

      assert Keywords.list_keywords(user) == []
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keywords(user, ["first keyword", "second keyword", "third keyword"])
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

  describe "get_keyword!/2" do
    test "given a valid keyword ID, returns the keyword" do
      %User{id: user_id} = user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)

      %KeywordLookup{id: keyword_lookup_id} =
        _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      keyword = Keywords.get_keyword!(user, keyword_id)

      assert keyword.id == keyword_id
      assert keyword.user_id == user_id
      assert keyword.keyword_lookup.id == keyword_lookup_id
    end

    test "given a valid keyword ID but INVALID user ID, raises Ecto.NoResultsError" do
      user = insert(:user)
      another_user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      assert_raise Ecto.NoResultsError, fn ->
        Keywords.get_keyword!(another_user, keyword_id)
      end
    end

    test "given empty keyword ID, raises ArgumentError" do
      user = insert(:user)

      assert_raise ArgumentError, fn ->
        Keywords.get_keyword!(user, nil)
      end
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      assert_raise FunctionClauseError, fn ->
        Keywords.get_keyword!(nil, keyword_id)
      end
    end
  end

  describe "update_status!/2" do
    test "given a keyword and a status, returns :ok with the updated keyword" do
      %Keyword{status: keyword_status} = keyword = insert(:keyword, status: :new)

      assert keyword_status == :new

      assert %Keyword{status: updated_keyword_status} = Keywords.update_status!(keyword, :completed)

      assert updated_keyword_status == :completed
    end

    test "given EMPTY keyword and a status, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        Keywords.update_status!(nil, :completed)
      end
    end

    test "given a keyword and INVALID status, raises Ecto.ChangeError" do
      %Keyword{status: keyword_status} = keyword = insert(:keyword, status: :new)

      assert keyword_status == :new

      assert_raise Ecto.ChangeError, fn ->
        Keywords.update_status!(keyword, :invalid_status)
      end
    end
  end

  describe "subscribe_keyword_update/1" do
    test "given the current process subscribes to the keyword update of the current user, receives {:updated, %Keyword{}}" do
      user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      assert :ok = Keywords.subscribe_keyword_update(user)

      Task.start(fn -> Keywords.broadcast_keyword_update(keyword) end)

      assert_receive({:updated, %Keyword{id: ^keyword_id}})
    end

    test "given the current process subscribes to the keyword update of the another user, receives NOTHING" do
      user = insert(:user)
      another_user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      assert :ok = Keywords.subscribe_keyword_update(another_user)

      Task.start(fn -> Keywords.broadcast_keyword_update(keyword) end)

      refute_receive({:updated, %Keyword{id: ^keyword_id}})
    end

    test "given the current process does NOT subscribe to the keyword update, receives NOTHING" do
      user = insert(:user)
      %Keyword{id: keyword_id} = keyword = insert(:keyword, user: user)
      _keyword_lookup = insert(:keyword_lookup, keyword: keyword)

      Task.start(fn -> Keywords.broadcast_keyword_update(keyword) end)

      refute_receive({:updated, %Keyword{id: ^keyword_id}})
    end
  end

  describe "broadcast_keyword_update/1" do
    test "given a keyword, returns :ok" do
      user = insert(:user)
      keyword = insert(:keyword, user: user)
      insert(:keyword_lookup, keyword: keyword)

      assert :ok = Keywords.broadcast_keyword_update(keyword)
    end
  end
end
