defmodule Echoes.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :active, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false
      add :denied, :boolean, default: false, null: false
      add :pin_order, :integer
      add :owner, :boolean, default: false, null: false
      add :moderator, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :chat_id, references(:chats, on_delete: :nothing)

      timestamps()
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:chat_id])
  end
end
