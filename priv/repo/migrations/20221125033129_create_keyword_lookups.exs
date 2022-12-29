defmodule ElixirInternalCertification.Repo.Migrations.CreateKeywordLookups do
  use Ecto.Migration

  def change do
    create table(:keyword_lookups) do
      add :keyword_id, references(:keywords, on_delete: :delete_all), null: false
      add :html, :text, null: false
      add :number_of_adwords_advertisers, :integer, null: false
      add :number_of_adwords_advertisers_top_position, :integer, null: false
      add :urls_of_adwords_advertisers_top_position, {:array, :text}, null: false
      add :number_of_non_adwords, :integer, null: false
      add :urls_of_non_adwords, {:array, :text}, null: false
      add :number_of_links, :integer, null: false

      timestamps()
    end

    create index(:keyword_lookups, [:keyword_id])
  end
end
