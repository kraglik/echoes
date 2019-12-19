defmodule Echoes.Chat do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Echoes.{Repo, User, Chat, Message, Membership}

  @timestamps_opts [type: :utc_datetime_usec]
  schema "chats" do
    field :active, :boolean, default: true
    field :banned, :boolean, default: false
    field :data, :map
    field :last_event_at, :utc_datetime
    field :type, :string

    timestamps()
  end

  def create_dialog(user_id, other_user_id) do

#    case Repo.one
    dialog = Repo.insert(%Chat{
      last_event_at: DateTime.utc_now,
      type: "dialog",
      data: %{}
    })
#    memberships
  end

  def get_for_user(user_id, count, offset_count) do
    query = from c in Chat,
                 left_join: m in Membership,
                 where: m.user_id == ^user_id,
                 where: m.active and not (m.banned or m.denied),
                 limit: ^count,
                 offset: ^offset_count,
                 select: c
    Repo.all(query)
  end

  def members(%Chat{id: id}=chat) do
    users_ids = Repo.all(from m in Membership, where: m.chat_id == ^id, select: m.user_id)
    users = Enum.map(users_ids, fn user_id -> Repo.get(User, user_id) end)
    Enum.map(users, fn user ->
      %{
        id: user.id,
        name: user.name,
        username: user.username
      }
    end)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
      |> cast(attrs, [:type, :last_event_at, :active, :banned, :data])
      |> validate_required([:type, :last_event_at, :active, :banned, :data])
  end
end
