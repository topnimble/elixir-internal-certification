defmodule ElixirInternalCertification.GuardianTest do
  use ElixirInternalCertification.DataCase, async: true

  alias ElixirInternalCertification.Guardian
  alias ElixirInternalCertification.Account.Schemas.User

  describe "subject_for_token/2" do
    test "given a user, returns :ok with stringified user ID" do
      %User{id: user_id} = user = insert(:user)

      assert Guardian.subject_for_token(user, %{}) == {:ok, to_string(user_id)}
    end

    test "given an EMPTY user, returns {:error, :unhandled_resource_type}" do
      assert Guardian.subject_for_token(nil, %{}) == {:error, :unhandled_resource_type}
    end
  end

  describe "resource_from_claims/1" do
    test "given a JWT with user ID, returns {:ok, %User{}}" do
      %User{id: user_id} = _user = insert(:user)

      jwt = %{"sub" => to_string(user_id)}

      assert {:ok, %User{id: ^user_id}} = Guardian.resource_from_claims(jwt)
    end

    test "given an EMPTY JWT, returns {:error, :unhandled_resource_type}" do
      assert Guardian.resource_from_claims(nil) == {:error, :unhandled_resource_type}
    end

    test "given a JWT with non-existence user ID, returns {:error, :invalid_claims}" do
      jwt = %{"sub" => "-1"}

      assert Guardian.resource_from_claims(jwt) == {:error, :invalid_claims}
    end
  end
end
