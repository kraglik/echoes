defmodule Echoes.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :avatar_url, :string
      add :avatar_origin, :string
      add :username, :string, unique: true
      add :email, :string, unique: true
      add :name, :string
      add :password_hash, :string
      add :last_online_at, :utc_datetime
      add :active, :boolean, default: false, null: false
      add :banned, :boolean, default: false, null: false

      timestamps()
    end

  end
end
