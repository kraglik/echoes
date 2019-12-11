defmodule EchoesWeb.LoginView do
  use EchoesWeb, :view
  alias EchoesWeb.LoginView

  def render("login.json", %{token: {_, token, _}}) do
    %{
      status: :success,
      token: token
    }
  end

  def render("login.json", %{user: nil}) do
    %{
      status: :error,
      reason: "user not found"
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