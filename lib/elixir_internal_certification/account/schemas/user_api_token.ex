defmodule ElixirInternalCertification.Account.Schemas.UserApiToken do
  use Ecto.Schema

  @default_token_type "Bearer"

  embedded_schema do
    field :token, :string, redact: true
    field :token_type, :string, default: @default_token_type
  end

  def new(%{token: token} = _attrs) do
    %__MODULE__{
      token: token
    }
  end
end
