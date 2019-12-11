defmodule Echoes.Chat do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Echoes.{Repo, User, Chat, Message, Membership}

  schema "chats" do
    field :active, :boolean, default: true
    field :banned, :boolean, default: false
    field :data, :map
    field :last_event_at, :utc_datetime
    field :type, :string

    timestamps()
  end

  def create_dialog(user_id, other_user_id) do
    {_, last_event_at} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now)
    dialog = %Chat{
      last_event_at: last_event_at,
      type: "dialog",
      data: %{}
    }
  end

  def get_for_user(user_id, count, offset_count) do
    query = from c in Chat,
                 left_join: m in Membership,
                 where: m.user_id == ^user_id,
                 where: m.active and not (m.banned or m.denied),
                 limit: ^count,
                 offset: ^offset_count
  end

  @doc false
  def changeset(chat, attrs) do
    chat
      |> cast(attrs, [:type, :last_event_at, :active, :banned, :data])
      |> validate_required([:type, :last_event_at, :active, :banned, :data])
  end
end
