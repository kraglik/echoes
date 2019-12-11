defmodule Echoes.StickerPack do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stickerpacks" do
    field :hide_author, :boolean, default: false
    field :title, :string
    field :author_id, :id

    timestamps()
  end

  @doc false
  def changeset(sticker_pack, attrs) do
    sticker_pack
    |> cast(attrs, [:title, :hide_author])
    |> validate_required([:title, :hide_author])
  end
end
