defmodule ElixirInternalCertification.Keywords.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias ElixirInternalCertification.Account.Schemas.User

  schema "keywords" do
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user, keyword, attrs) do
    keyword
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> put_assoc(:user, user)
    |> assoc_constraint(:user)
  end
end
