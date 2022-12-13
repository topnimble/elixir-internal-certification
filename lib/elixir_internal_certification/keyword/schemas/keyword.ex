# credo:disable-for-next-line CompassCredoPlugin.Check.RepeatingFragments
defmodule ElixirInternalCertification.Keyword.Schemas.Keyword do
  use Ecto.Schema

  alias ElixirInternalCertification.Account.Schemas.User

  schema "keywords" do
    field :title, :string

    belongs_to :user, User

    timestamps()
  end
end
