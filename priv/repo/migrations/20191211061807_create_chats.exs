defmodule Echoes.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :type, :string
      add :last_event_at, :utc_datetime_usec
      add :active, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false
      add :data, :map

      timestamps()
    end

  end
end
