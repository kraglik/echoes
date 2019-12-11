defmodule Echoes.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :type, :string
      add :content, :map
      add :author_id, references(:users, on_delete: :nothing)
      add :chat_id, references(:chats, on_delete: :nothing)
      add :origin_id, references(:chats, on_delete: :nothing)

      timestamps()
    end

    create index(:messages, [:author_id])
    create index(:messages, [:chat_id])
    create index(:messages, [:origin_id])
  end
end
