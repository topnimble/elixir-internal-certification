defmodule ElixirInternalCertification.AccountsTest do
  use ElixirInternalCertification.DataCase

  import ElixirInternalCertification.AccountsFixtures

  alias ElixirInternalCertification.Accounts
  alias ElixirInternalCertification.Accounts.{User, UserToken}

  describe "get_user_by_email/1" do
    test "given the email exists, returns the user" do
      %{id: id} = user = insert(:user)

      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end

    test "given the email does NOT exist, does NOT return the user" do
      assert Accounts.get_user_by_email("unknown@example.com") == nil
    end

    test "given the email is nil, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        Accounts.get_user_by_email(nil)
      end
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "given the email and password are valid, returns the user" do
      password = valid_user_password()
      %{id: id} = user = insert(:user, password: password)

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, password)
    end

    test "given the email does NOT exist, does NOT return the user" do
      assert Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!") == nil
    end

    test "given the password is NOT valid, does NOT return the user" do
      user = insert(:user)
      assert Accounts.get_user_by_email_and_password(user.email, "invalid") == nil
    end

    test "given the email and password are nil, raises FunctionClauseError" do
      assert_raise FunctionClauseError, fn ->
        Accounts.get_user_by_email_and_password(nil, nil)
      end
    end
  end

  describe "get_user!/1" do
    test "given ID is valid, returns the user with the given ID" do
      %{id: id} = user = insert(:user)
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end

    test "given ID is INVALID, raises Ecto.NoResultsError" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "given ID is nil, raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Accounts.get_user!(nil)
      end
    end
  end

  describe "register_user/1" do
    test "given email and password, validates email and password" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "given an email, registers users with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end

    test "given EMPTY email and password, requires email and password to be set" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "given email and password are too long, validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "given a duplicated email, validates email uniqueness" do
      %{email: email} = insert(:user)
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset_2} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset_2).email
    end
  end

  describe "change_user_registration/2" do
    test "given a changeset, returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "given a changeset and valid user attributes, allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: insert(:user)}
    end

    test "given a user, generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: insert(:user).id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "given a valid token, returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "given an INVALID token, does NOT return user for invalid token" do
      assert Accounts.get_user_by_session_token("oops") == nil
    end

    test "given an EXPIRED token, does NOT return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  describe "delete_session_token/1" do
    test "given a token, deletes the token" do
      user = insert(:user)
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  describe "inspect/2" do
    test "given a password, does NOT include password" do
      assert inspect(%User{password: "123456"}) =~ "password: \"123456\"" == false
    end
  end
end
