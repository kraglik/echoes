defmodule EchoesWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "chat:*", EchoesWeb.ChatChannel

  def connect(%{"token" => token}=_params, socket, _connect_info) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        case Guardian.resource_from_claims(claims) do
          {:ok, user} when user != nil ->
            {:ok, assign(socket, :user_id, user.id)}
          _ ->
            :error
        end
      _ -> :error
    end
  end

  def connect(_params, _socket, _connection_info) do
    :error
  end

  def id(_socket), do: nil
end
