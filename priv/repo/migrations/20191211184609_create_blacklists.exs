defmodule Echoes.Repo.Migrations.CreateBlacklists do
  use Ecto.Migration

  def change do
    create table(:blacklists) do
      add :owner_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:blacklists, [:owner_id])
    create index(:blacklists, [:user_id])
  end
end
