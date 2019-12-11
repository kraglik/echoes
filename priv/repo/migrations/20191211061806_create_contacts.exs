defmodule Echoes.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :name, :string
      add :blacklisted, :boolean, default: false, null: false
      add :owner_id, references(:users, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:contacts, [:owner_id])
    create index(:contacts, [:user_id])
  end
end
