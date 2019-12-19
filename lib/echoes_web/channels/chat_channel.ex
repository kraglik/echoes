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
      broadcast_from!(socket, "message", %{
        body: %{
          created_at: message.inserted_at,
          type: "message",
          content: content,
          author: socket.assigns.user_id,
          id: message.id,
          chat: message.chat_id
        }
      })
      push(socket, "message", %{
        body: %{
          created_at: message.inserted_at,
          type: "message",
          content: content,
          author: socket.assigns.user_id,
          id: message.id,
          local_id: id,
          chat: message.chat_id
        }
      })
    end
    {:noreply, socket}
  end

  def handle_in("load_messages", %{"offset" => offset}, %{topic: "chat:" <> chat_id}=socket) do
    {chat_id, _} = Integer.parse chat_id

    messages = Message.with_offset(chat_id, 100, offset)

    push(socket, "messages_loaded", %{
      body: %{
        messages: Enum.map(messages, fn m ->
          %{
            created_at: m.inserted_at,
            type: "message",
            content: m.content,
            author: m.author_id,
            id: m.id,
            local_id: nil,
            chat: m.chat_id
          }
        end)
      }
    })

    {:noreply, socket}
  end

end