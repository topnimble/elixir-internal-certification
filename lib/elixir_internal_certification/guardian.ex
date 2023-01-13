defmodule ElixirInternalCertification.Guardian do
  use Guardian, otp_app: :elixir_internal_certification

  alias ElixirInternalCertification.Account.Accounts

  def subject_for_token(resource, _claims), do: {:ok, to_string(resource.id)}

  def resource_from_claims(claims), do: Accounts.get_user_by_id!(claims["sub"])
end
