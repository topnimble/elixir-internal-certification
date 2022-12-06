defmodule ElixirInternalCertification.Keyword.KeywordsTest do
  use ElixirInternalCertification.DataCase

  import ExUnit.CaptureLog

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword
  alias ElixirInternalCertification.Keyword.Keywords

  require Logger

  @fixture_path "test/support/fixtures"

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

      logs = capture_log(fn ->
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
