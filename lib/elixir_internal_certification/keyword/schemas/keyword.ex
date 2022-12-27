# credo:disable-for-next-line CompassCredoPlugin.Check.RepeatingFragments
defmodule ElixirInternalCertification.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias ElixirInternalCertification.Account.Schemas.User

  @statuses [:pending, :completed, :failed]

  schema "keywords" do
    field :title, :string
    field :status, Ecto.Enum, values: @statuses, default: :pending

    belongs_to :user, User

    timestamps()
  end

  def update_status_changeset(keyword \\ %__MODULE__{}, attrs) do
    keyword
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  def changeset(%User{} = user, keyword \\ %__MODULE__{}, attrs) do
    keyword
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> put_assoc(:user, user)
    |> assoc_constraint(:user)
  end
end
