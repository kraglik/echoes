defmodule Echoes.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :type, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :url, :type])
    |> validate_required([:filename, :url, :type])
  end
end
