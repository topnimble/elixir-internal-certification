defmodule ElixirInternalCertification.Keyword.KeywordsTest do
  use ElixirInternalCertification.DataCase

  import ExUnit.CaptureLog

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Keywords
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  require Logger

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

      keywords = Keywords.list_keywords(user)

      assert keywords == []
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.list_keywords(user)
      end
    end
  end

  describe "create_keyword/2" do
    @valid_attrs %{title: "some title"}
    @invalid_attrs %{title: nil}

    test "given valid attributes, returns {:ok, %Keyword{}}" do
      %User{id: user_id} = user = insert(:user)

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(user, @valid_attrs)
      assert keyword.title == "some title"
      assert keyword.user_id == user_id
    end

    test "given INVALID attributes, returns {:error, %Ecto.Changeset{}}" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} = Keywords.create_keyword(user, @invalid_attrs)
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.create_keyword(user, @valid_attrs)
      end
    end
  end

  describe "save_keyword_to_database/2" do
    @valid_attrs "some title"
    @invalid_attrs nil

    test "given valid attributes, returns {:ok, %Keyword{}}" do
      %User{id: user_id} = user = insert(:user)

      assert {:ok, %Keyword{} = keyword} = Keywords.save_keyword_to_database(user, @valid_attrs)
      assert keyword.title == "some title"
      assert keyword.user_id == user_id
    end

    test "given INVALID attributes, returns {:error, %Ecto.Changeset{}}" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} = Keywords.save_keyword_to_database(user, @invalid_attrs)
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.save_keyword_to_database(user, @valid_attrs)
      end
    end
  end

  describe "parse_csv!/2" do
    test "given a path and a callback" do
      path = Path.join([@fixture_path, "/assets/keywords.csv"])

      logs =
        capture_log(fn ->
          Keywords.parse_csv!(path, fn line_of_keywords ->
            keyword = List.first(line_of_keywords)
            Logger.info(keyword)
          end)
        end)

      assert logs =~ "first keyword"
      assert logs =~ "second keyword"
      assert logs =~ "third keyword"
    end

    test "given a callback is nil, raises FunctionClauseError" do
      path = Path.join([@fixture_path, "/assets/keywords.csv"])

      assert_raise FunctionClauseError, fn ->
        Keywords.parse_csv!(path, nil)
      end
    end

    test "given a path is nil, raises FunctionClauseError" do
      path = nil

      assert_raise FunctionClauseError, fn ->
        Keywords.parse_csv!(path, fn line_of_keywords ->
          keyword = List.first(line_of_keywords)
          Logger.info(keyword)
        end)
      end
    end

    test "given a path which file does NOT exist, raises File.Error" do
      path = Path.join([@fixture_path, "/assets/non_existence_file.csv"])

      assert_raise File.Error, fn ->
        Keywords.parse_csv!(path, fn line_of_keywords ->
          keyword = List.first(line_of_keywords)
          Logger.info(keyword)
        end)
      end
    end
  end
end
