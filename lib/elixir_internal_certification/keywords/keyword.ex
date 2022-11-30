defmodule ElixirInternalCertification.Keywords.Keyword do
  use Ecto.Schema
  import Ecto.Changeset

  schema "keywords" do
    field :title, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
