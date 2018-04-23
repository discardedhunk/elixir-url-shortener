defmodule Shortener.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :original, :string
      add :shortened, :string

      timestamps()
    end

    create unique_index(:urls, :original)
    create unique_index(:urls, :shortened)
  end
end
