defmodule Echoes.Chat do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Echoes.{Repo, User, Chat, Message, Membership, MessageRead}

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
    query = from m in Membership,
                 inner_join: c in Chat, on: m.chat_id == c.id,
                 inner_join: m2 in Membership, on: m2.chat_id == c.id and m2.user_id == ^other_user_id,

                 where: c.type == "dialog",
                 where: m2.chat_id == m.chat_id,
                 where: m.user_id == ^user_id,

                 group_by: m.chat_id,
                 select: m.chat_id

    chat_id = Repo.one(query)

    case chat_id do
      nil ->
        {_, dt} = Ecto.Type.cast(:utc_datetime, DateTime.utc_now)
        {_, dialog} = Repo.insert(%Chat{
          last_event_at: dt,
          type: "dialog",
          data: %{}
        })
        {_, m1} = Repo.insert(%Membership{
         user_id: user_id,
         chat_id: dialog.id
        })
        {_, m2} = Repo.insert(%Membership{
          user_id: other_user_id,
          chat_id: dialog.id
        })
        {_, first_message} = Repo.insert(%Message{
          author_id: user_id,
          content: %{event: "created"},
          type: "info",
          chat_id: dialog.id,
          origin_id: nil
        })
        Repo.insert(
          %MessageRead{
            user_id: user_id,
            message_id: first_message
          }
        )
        {:ok, dialog}
      _ ->
        {:error, nil}
    end
  end

  def get_for_user(user_id, count, offset_count) do
    memberships_query = from m in Membership,
                 where: m.user_id == ^user_id,
                 where: m.active and not (m.banned or m.denied),
                 limit: ^count,
                 offset: ^offset_count,
                 select: m,
                 distinct: [m.chat_id]

    query = from c in Chat, join: m in subquery(memberships_query), on: c.id == m.chat_id
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
