defmodule ElixirInternalCertification.Account.Schemas.UserApiToken do
  use Ecto.Schema

  alias Ecto.ULID

  @default_token_type "Bearer"

  embedded_schema do
    field :token, :string, redact: true
    field :token_type, :string, default: @default_token_type
  end

  def new(%{token: token} = _attrs) do
    %__MODULE__{
      id: ULID.generate(),
      token: token
    }
  end
end
