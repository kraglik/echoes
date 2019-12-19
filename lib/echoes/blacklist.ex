defmodule Echoes.Blacklist do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "blacklists" do
    field :owner_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(blacklist, attrs) do
    blacklist
    |> cast(attrs, [])
    |> validate_required([])
  end
end
