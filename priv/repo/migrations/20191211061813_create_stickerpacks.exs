defmodule Echoes.Repo.Migrations.CreateStickerpacks do
  use Ecto.Migration

  def change do
    create table(:stickerpacks) do
      add :title, :string
      add :hide_author, :boolean, default: false, null: false
      add :author_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:stickerpacks, [:author_id])
  end
end
