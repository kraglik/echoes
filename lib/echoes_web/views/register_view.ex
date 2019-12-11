defmodule EchoesWeb.RegisterView do
  use EchoesWeb, :view

  def render("registered.json", %{token: {_, token, _}, id: id}) do
    %{
      status: :success,
      token: token,
      id: id
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