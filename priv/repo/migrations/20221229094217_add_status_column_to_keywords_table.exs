defmodule ElixirInternalCertification.Repo.Migrations.AddStatusColumnToKeywordsTable do
  use Ecto.Migration

  def change do
    alter table(:keywords) do
      add :status, :string, null: false
    end
  end
end
