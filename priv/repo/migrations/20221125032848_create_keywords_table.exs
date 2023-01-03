defmodule ElixirInternalCertification.Repo.Migrations.CreateKeywordsTable do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :title, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:keywords, [:user_id])
  end
end
