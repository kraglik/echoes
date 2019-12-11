defmodule Echoes.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :blacklisted, :boolean, default: false
    field :name, :string
    field :owner_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:name, :blacklisted])
    |> validate_required([:name, :blacklisted])
  end
end
