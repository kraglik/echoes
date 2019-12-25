defmodule Echoes.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Echoes.{Repo, Message, MessageRead, User}

  @timestamps_opts [type: :utc_datetime_usec]
  schema "messages" do
    field :content, :map
    field :type, :string
    field :author_id, :id
    field :chat_id, :id
    field :origin_id, :id

    timestamps()
  end

  def create(author_id, chat_id, origin_id, message_type, content) do
    message = %Message{
      author_id: author_id,
      chat_id: chat_id,
      origin_id: origin_id,
      type: message_type,
      content: content
    }

    with {_, message} = Repo.insert(message) do
      read(author_id, message.id)
      message
    end
  end

  def already_read(user_id, message_id) do
    query = from r in MessageRead,
                 where: r.user_id == ^user_id,
                 where: r.message_id == ^message_id,
                 select: count(r.id)

    case Repo.one(query) do
      0 -> false
      _ -> true
    end
  end

  defp read(user_id, message_id) do
    if not already_read(user_id, message_id) do
      _ = Repo.insert(%MessageRead{user_id: user_id, message_id: message_id})
      true
    else
      false
    end
  end

  def before_id(message_id, chat_id, count) do
    query = from m in Message,
                 where: m.id < ^message_id,
                 where: m.chat_id == ^chat_id,
                 limit: ^count

    get_messages(query)
  end

  def with_offset(chat_id, limit, offset) do
    query = from m in Message,
              where: m.chat_id == ^chat_id,
              order_by: m.id,
              limit: ^limit,
              offset: ^offset

    Repo.all(query)
  end

  def before_id_for_user(user_id, chat_id, message_id, count) do
    query = from m in Message,
                 where: m.id < ^message_id,
                 where: m.chat_id == ^chat_id,
                 limit: ^count,
                 group_by: m.id,
                 order_by: [asc: m.id]

    get_messages(query)
  end

  def after_id(message_id, chat_id, count) do
    query = from m in Message,
                 left_join: r in MessageRead,
                 where: m.id > ^message_id,
                 where: m.chat_id == ^chat_id,
                 limit: ^count,
                 group_by: m.id,
                 select: {m, count(r.id)}

    get_messages(query)
  end

  def after_id_for_user(user_id, chat_id, message_id, count) do
    query = from m in Message,
                 left_join: r in MessageRead,
                 where: m.id > ^message_id,
                 where: r.user_id == ^user_id,
                 where: m.chat_id == ^chat_id,
                 limit: ^count,
                 group_by: m.id,
                 select: {m, count(r.id)}

    get_messages(query)
  end

  def reads(message_id) do
    query = from r in MessageRead,
                 where: r.message_id == ^message_id,
                 select: count(r.id)

    Repo.one(query)
  end

  def last_message(chat_id, user_id) do
    query = from m in Message,
                 left_join: r in MessageRead,
                 on: m.id == r.message_id,
                 on: r.user_id == ^user_id,
                 where: m.chat_id == ^chat_id,
                 group_by: m.id,
                 order_by: [desc: m.id],
                 limit: 1,
                 select: {m, count(r.id)}

    case get_messages(query) do
      [message] ->
        %{
          created_at: message.inserted_at,
          type: message.type,
          content: message.content,
          author: message.author_id,
          id: message.id,
          local_id: nil,
          chat: message.chat_id,
          reads: message.reads
        }
      [] ->
        nil
    end
  end

  defp get_messages(query) do
    Repo.all(query)
    |> Enum.map(fn(message) ->
       Map.put(message, :reads, 1)
     end)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:type, :content])
    |> validate_required([:type, :content])
  end
end
