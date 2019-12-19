defmodule EchoesWeb.UserChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias Echoes.{Membership, User, Chat, Membership, Message, Repo}
  alias EchoesWeb.Endpoint

  def join("user:" <> chat_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("create_dialog", %{user_id: target_user_id}, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    with {status, dialog} = Chat.create_dialog(socket.assigns.user_id, target_user_id) do
      case status do
        :ok ->
          user = Repo.get(User, user_id)
          target_user = Repo.get(User, target_user_id)

          Endpoint.broadcast_from!(self(), "user:" <> target_user_id, "new_dialog", %{
            body: %{
              dialog: dialog.id,
              user: %{
                id: socket.assigns.user_id
              }
            }
          })
          Endpoint.broadcast_from!(self(), "user:" <> user_id, "new_dialog", %{
            body: %{
              dialog: dialog.id,
              user: %{
                id: target_user_id
              }
            }
          })
        :error ->
          nil
      end
    end
    {:noreply, socket}
  end

  def handle_in("load_self", nil, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    case user = Repo.get(User, user_id) do
      nil -> nil
      user -> broadcast!(socket, "self_loaded", %{
        body: %{
          user: %{
            id: user.id,
            name: user.name,
            username: user.username,
            email: user.email
          }
        }
      })
    end
    {:noreply, socket}
  end

  def handle_in("load_chats", %{"offset" => offset}, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    with chats = Chat.get_for_user(user_id, 10, offset) do
      chats = Enum.map(chats, fn c ->
        %{
          members: Chat.members(c),
          id: c.id,
          data: c.data,
          type: c.type
        }
      end)
      broadcast!(socket, "chats_loaded", %{
        body: %{
          chats: chats
        }
      })
    end
    {:noreply, socket}
  end

end