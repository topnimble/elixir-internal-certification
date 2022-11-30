defmodule ElixirInternalCertification.Repo.Migrations.CreateKeywordLookups do
  use Ecto.Migration

  def change do
    create table(:keyword_lookups) do
      add :keyword_id, references(:keywords)
      add :html, :text
      add :number_of_adwords_advertisers, :integer
      add :number_of_adwords_advertisers_top_position, :integer
      add :urls_of_adwords_advertisers_top_position, {:array, :string}
      add :number_of_non_adwords, :integer
      add :urls_of_non_adwords, {:array, :string}
      add :number_of_links, :integer

      timestamps()
    end
  end
end
