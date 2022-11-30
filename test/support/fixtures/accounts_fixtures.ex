defmodule ElixirInternalCertification.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ElixirInternalCertification.Account.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
end
