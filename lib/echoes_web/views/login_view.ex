defmodule EchoesWeb.LoginView do
  use EchoesWeb, :view
  alias EchoesWeb.LoginView
  alias Echoes.User

  def render("login.json", %{token: {_, token, _}, user: %User{}=user}) do
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

  def render("login.json", %{token: nil, user: nil}) do
    %{
      status: :error,
      reason: "user not found"
    }
  end

  def render("login.json", %{token: nil, user: %User{}}) do
    %{
      status: :error,
      reason: "wrong password"
    }
  end

  def render("login.json", %{password: nil}) do
    %{
      status: :error,
      reason: "password"
    }
  end

  def render("login.json", %{correct: false}) do
    %{
      status: :error,
      reason: "wrong data"
    }
  end
end