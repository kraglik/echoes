defmodule Echoes.Sticker do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :utc_datetime_usec]
  schema "stickers" do
    field :message, :string
    field :url, :string
    field :stickerpack, :id

    timestamps()
  end

  @doc false
  def changeset(sticker, attrs) do
    sticker
    |> cast(attrs, [:url, :message])
    |> validate_required([:url, :message])
  end
end
