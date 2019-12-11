defmodule Echoes.Repo.Migrations.CreateMessageReads do
  use Ecto.Migration

  def change do
    create table(:message_reads) do
      add :user_id, references(:users, on_delete: :nothing)
      add :message_id, references(:messages, on_delete: :nothing)

      timestamps()
    end

    create index(:message_reads, [:user_id])
    create index(:message_reads, [:message_id])
  end
end
