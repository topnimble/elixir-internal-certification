defmodule ElixirInternalCertification.Repo.Migrations.CreateKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :title, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:keywords, [:user_id])
  end
end
