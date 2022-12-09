defmodule ElixirInternalCertification.Keyword.KeywordsTest do
  use ElixirInternalCertification.DataCase

  alias ElixirInternalCertification.Keyword.Keywords

  describe "list_keywords/1" do
    test "given a user, returns a list of keywords belongs to the user" do
      user = insert(:user)
      another_user = insert(:user)

      insert(:keyword, user: user, title: "first keyword")
      insert(:keyword, user: user, title: "second keyword")
      insert(:keyword, user: user, title: "third keyword")
      insert(:keyword, user: another_user, title: "another keyword")

      keywords = Keywords.list_keywords(user)

      assert length(keywords) == 3

      assert MapSet.equal?(
               MapSet.new(Enum.map(keywords, fn keyword -> keyword.title end)),
               MapSet.new(["first keyword", "second keyword", "third keyword"])
             ) == true
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
end
