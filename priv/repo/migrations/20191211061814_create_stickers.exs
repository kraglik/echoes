defmodule Echoes.Repo.Migrations.CreateStickers do
  use Ecto.Migration

  def change do
    create table(:stickers) do
      add :url, :string
      add :message, :string
      add :stickerpack, references(:stickerpacks, on_delete: :nothing)

      timestamps()
    end

    create index(:stickers, [:stickerpack])
  end
end
