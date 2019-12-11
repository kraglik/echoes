defmodule EchoesWeb.UserChannel do
  use Phoenix.Channel
  import Ecto.Query
  alias Echoes.{Membership, User, Chat, Membership, Message, Repo}
  alias EchoesWeb.Endpoint

  def join("chat:" <> chat_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("create_dialog", %{user_id: target_user_id}, %{topic: "chat:" <> chat_id}=socket) do
    with {status, dialog} = Chat.create_dialog(socket.assigns.user_id, target_user_id) do
      case status do
        :ok ->
          Endpoint.broadcast_from!(self(), "user:" <> target_user_id, "new_dialog", %{
            body: %{
              dialog: dialog.id,
              user: socket.assigns.user_id
            }
          })
        :error ->
          nil
      end
    end
    {:noreply, socket}
  end

end