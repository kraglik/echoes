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

  def handle_in("message", %{content: content, id: id}, %{topic: "chat:" <> chat_id}=socket) do
    {:noreply, socket}
  end

end