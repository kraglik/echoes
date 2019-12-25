defmodule EchoesWeb.UserChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias Echoes.{Membership, User, Chat, Membership, Message, Repo}
  alias EchoesWeb.Endpoint

  def join("user:" <> chat_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("create_dialog", %{"user_id" => target_user_id}, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    with {status, dialog} = Chat.create_dialog(socket.assigns.user_id, target_user_id) do
      case status do
        :ok ->
          user = Repo.get(User, user_id)
          target_user = Repo.get(User, target_user_id)

          socket.endpoint.broadcast!("user:#{target_user_id}", "dialog_created", %{
            body: %{
              dialog: dialog.id,
              user: %{
                id: user.id,
                name: user.name,
                username: user.username
              }
            }
          })
          socket.endpoint.broadcast!("user:#{user_id}", "dialog_created", %{
            body: %{
              dialog: dialog.id,
              user: %{
                id: target_user.id,
                name: target_user.name,
                username: target_user.username
              }
            }
          })
        :error ->
          broadcast!(socket, "dialog_creation_error", %{body: nil})
      end
    end
    {:noreply, socket}
  end

  def handle_in("create_dialog", %{"username" => target_username}, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    with target_user = Repo.get_by(User, username: target_username) do
      case target_user do
        nil ->
          push(socket, "dialog_creation_failed", %{body: nil})
          {:noreply, socket}
        %User{id: target_user_id} when target_user_id == user_id ->
          push(socket, "dialog_creation_failed", %{body: nil})
          {:noreply, socket}
        _ ->
          with {status, dialog} = Chat.create_dialog(socket.assigns.user_id, target_user.id) do
            case status do
              :ok ->
                user = Repo.get(User, user_id)

                socket.endpoint.broadcast!("user:#{target_user.id}", "dialog_created", %{
                  body: %{
                    dialog: %{
                      id: dialog.id,
                      type: dialog.type,
                      data: dialog.data,
                      members: Chat.members(dialog),
                      last_message: dialog.last_message
                    },
                    user: %{
                      id: user.id,
                      name: user.name,
                      username: user.username
                    }
                  }
                })
                socket.endpoint.broadcast!("user:#{user_id}", "dialog_created", %{
                  body: %{
                    dialog: %{
                      id: dialog.id,
                      type: dialog.type,
                      data: dialog.data,
                      members: Chat.members(dialog),
                      last_message: dialog.last_message
                    },
                    user: %{
                      id: target_user.id,
                      name: target_user.name,
                      username: target_user.username
                    }
                  }
                })
              :error ->
                push(socket, "dialog_creation_error", %{body: nil})
            end
          end
      end
    end
    {:noreply, socket}
  end

  def handle_in(
        "users_like",
        %{"username" => username_part, "offset" => offset},
        %{topic: "user:" <> user_id}=socket
      ) do

    users = User.find_alike(username_part, offset, 20)

    push(socket, "users_like", %{
      body: Enum.map(users, fn user ->
        %{
          id: user.id,
          name: user.name,
          username: user.username,
          avatar: user.avatar_url
        }
      end)
    })

    {:noreply, socket}
  end

  def handle_in("load_self", nil, %{topic: "user:" <> user_id}=socket) do
    {user_id, _} = Integer.parse user_id
    case user = Repo.get(User, user_id) do
      nil -> nil
      user -> push(socket, "self_loaded", %{
        body: %{
          user: %{
            id: user.id,
            name: user.name,
            username: user.username,
            email: user.email,
            avatar: user.avatar_url
          }
        }
      })
    end
    {:noreply, socket}
  end

  def handle_in("load_chats", %{"offset" => offset}, socket) do
    with chats = Chat.get_for_user(socket.assigns.user_id, 10, offset) do
      chats = Enum.map(chats, fn c ->
        IO.inspect(Message.last_message(c.id, socket.assigns.user_id))
        %{
          members: Chat.members(c),
          id: c.id,
          data: c.data,
          type: c.type,
          last_message: Message.last_message(c.id, socket.assigns.user_id)
        }
      end)
      push(socket, "chats_loaded", %{
        body: %{
          chats: chats
        }
      })
    end
    {:noreply, socket}
  end

end