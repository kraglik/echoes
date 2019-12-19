defmodule EchoesWeb.RegisterView do
  use EchoesWeb, :view
  alias Echoes.User

  def render("registered.json", %{token: {_, token, _}, user: %User{}=user}) do
    %{
      status: :success,
      token: token,
      user: %{
        id: user.id,
        name: user.name,
        username: user.username
      }
    }
  end

  def render("register_failed.json", %{error: error}) do
    %{
      status: :error,
      reason: error
    }
  end

  def render("register_failed.json", _params) do
    %{
      status: :error,
      reason: "password"
    }
  end
end