defmodule ElixirInternalCertification.Guardian do
  use Guardian, otp_app: :elixir_internal_certification

  alias ElixirInternalCertification.Account.Accounts
  alias ElixirInternalCertification.Account.Schemas.User

  def subject_for_token(%User{id: user_id} = _resource, _options), do: {:ok, to_string(user_id)}
  def subject_for_token(_resource, _options), do: {:error, :unhandled_resource_type}

  def resource_from_claims(%{"sub" => sub} = _claims) do
    user_id = String.to_integer(sub)

    try do
      user = Accounts.get_user_by_id!(user_id)
      {:ok, user}
    rescue
      Ecto.NoResultsError -> {:error, :invalid_claims}
    end
  end

  def resource_from_claims(_claims), do: {:error, :unhandled_resource_type}
end
