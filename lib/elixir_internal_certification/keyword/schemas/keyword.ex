# credo:disable-for-next-line CompassCredoPlugin.Check.RepeatingFragments
defmodule ElixirInternalCertification.Keyword.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  alias ElixirInternalCertification.Account.Schemas.User
  alias ElixirInternalCertification.Keyword.Schemas.KeywordLookup

  @statuses [:new, :pending, :completed, :failed]

  schema "keywords" do
    field :title, :string
    field :status, Ecto.Enum, values: @statuses, default: :new
    has_one :keyword_lookup, KeywordLookup
    belongs_to :user, User

    timestamps()
  end

  def update_status_changeset(keyword, status), do: change(keyword, status: status)

  def changeset(%User{} = user, keyword \\ %__MODULE__{}, attrs) do
    keyword
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> put_assoc(:user, user)
    |> assoc_constraint(:user)
  end
end
