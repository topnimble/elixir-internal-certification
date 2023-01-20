defmodule ElixirInternalCertification.Account.Schemas.UserApiTokenTest do
  use ElixirInternalCertification.DataCase

  alias Ecto.ULID

  alias ElixirInternalCertification.Account.Schemas.UserApiToken

  describe "new/1" do
    test "given valid params, returns a valid changeset" do
      expect(ULID, :generate, fn -> "01GQ45DK0QQEWQY6J01HV3BWQW" end)

      assert UserApiToken.new(%{token: "123456"}) == %UserApiToken{
               id: "01GQ45DK0QQEWQY6J01HV3BWQW",
               token: "123456",
               token_type: "Bearer"
             }
    end

    test "given MISSING params, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        UserApiToken.new(nil)
      end
    end
  end
end
