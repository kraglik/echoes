defmodule Echoes.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string
      add :url, :string
      add :type, :string

      timestamps()
    end

  end
end
