defmodule ElixirInternalCertification.Keyword.Schemas.KeywordTest do
  use ElixirInternalCertification.DataCase

  alias Ecto.Changeset
  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.Keyword

  describe "changeset/3" do
    test "given valid params, returns a valid changeset" do
      %User{id: user_id} = user = insert(:user)

      changeset = Keyword.changeset(user, %{title: "keyword"})

      assert %Changeset{valid?: true, changes: %{title: "keyword"}} = changeset

      %Changeset{changes: %{user: user_changeset}} = changeset

      assert %Changeset{valid?: true, data: %User{id: ^user_id}} = user_changeset
    end

    test "given EMPTY params, returns an INVALID changeset" do
      user = insert(:user)

      changeset = Keyword.changeset(user, %{})

      assert %Changeset{valid?: false} = changeset

      assert "can't be blank" in errors_on(changeset).title
    end

    test "given INVALID params, returns an INVALID changeset" do
      user = insert(:user)

      changeset = Keyword.changeset(user, %{title: %{}})

      assert %Changeset{valid?: false} = changeset

      assert "is invalid" in errors_on(changeset).title
    end

    test "given a user is nil, raises FunctionClauseError" do
      user = nil

      assert_raise FunctionClauseError, fn ->
        Keyword.changeset(user, %{title: "keyword"})
      end
    end
  end

  describe "update_status_changeset/2" do
    test "given valid params, returns the keyword with updated status" do
      %Keyword{id: keyword_id} = keyword = insert(:keyword)

      {:ok, %Keyword{id: updated_keyword_id, status: updated_keyword_status}} =
        keyword
        |> Keyword.update_status_changeset(:completed)
        |> Repo.update()

      assert updated_keyword_id == keyword_id
      assert updated_keyword_status == :completed
    end

    test "given EMPTY params, raises Postgrex.Error" do
      keyword = insert(:keyword)

      assert_raise Postgrex.Error, fn ->
        {:error, _changeset} =
          keyword
          |> Keyword.update_status_changeset(nil)
          |> Repo.update()
      end
    end

    test "given INVALID params, raises Ecto.ChangeError" do
      keyword = insert(:keyword)

      assert_raise Ecto.ChangeError, fn ->
        {:error, _changeset} =
          keyword
          |> Keyword.update_status_changeset(:invalid_status)
          |> Repo.update()
      end
    end
  end
end
