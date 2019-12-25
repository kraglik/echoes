defmodule EchoesWeb.ChatChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias Echoes.{Membership, User, Chat, Membership, Message, Repo}

  def join("chat:" <> chat_id, _params, socket) do
    case Membership.get(chat_id, socket.assigns.user_id) do
      %Membership{id: membership_id} ->
        {:ok,    assign(socket, :membership_id, membership_id)}
      nil ->
        {:error, "Unauthorized"}
    end
  end

  def handle_in("message", %{"content" => content, "id" => id}, %{topic: "chat:" <> chat_id}=socket) do
    {chat_id, _} = Integer.parse chat_id
    if Membership.can_post(socket.assigns.user_id, socket.assigns.membership_id) do
      message = Message.create(socket.assigns.user_id, chat_id, nil, "message", content)
      author = Repo.get(User, socket.assigns.user_id)
      broadcast_from!(socket, "message", %{
        body: %{
          created_at: message.inserted_at,
          type: "message",
          content: content,
          author: %{
            username: author.username,
            id: author.id,
            name: author.name
          },
          id: message.id,
          chat: message.chat_id
        }
      })
      push(socket, "message", %{
        body: %{
          created_at: message.inserted_at,
          type: "message",
          content: content,
          author: %{
            username: author.username,
            id: author.id,
            name: author.name
          },
          id: message.id,
          local_id: id,
          chat: message.chat_id
        }
      })
    end
    {:noreply, socket}
  end

  def handle_in(
        "load_messages_before",
        %{"message_id" => message_id},
        %{topic: "chat:" <> chat_id}=socket
      ) do

    {chat_id, _} = Integer.parse chat_id

    messages = Message.before_id_for_user(socket.assigns.user_id, chat_id, message_id, 50)
    push_loaded_messages(socket, messages, "before")

    {:noreply, socket}
  end

  def handle_in(
        "load_messages_after",
        %{"message_id" => message_id},
        %{topic: "chat:" <> chat_id}=socket
      ) do

    {chat_id, _} = Integer.parse chat_id

    messages = Message.after_id_for_user(socket.assigns.user_id, chat_id, message_id, 50)
    push_loaded_messages(socket, messages, "after")

    {:noreply, socket}
  end

  defp push_loaded_messages(socket, messages, direction) do
    push(socket, "messages_loaded", %{
      body: %{
        direction: direction,
        messages: Enum.map(messages, fn m ->
          user = Repo.one(User, m.author_id)
          %{
            created_at: m.inserted_at,
            type: m.type,
            content: m.content,
            author: %{
              username: user.username,
              id: user.id,
              name: user.name
            },
            id: m.id,
            local_id: nil,
            chat: m.chat_id
          }
        end)
      }
    })
  end

end