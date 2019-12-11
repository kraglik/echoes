defmodule EchoesWeb.VerifyController do
  use EchoesWeb, :controller

  alias Echoes.{Repo, User, Guardian}
  alias Echoes.Guardian

  def verify(conn, %{"username" => username, "password" => password}) do
    case User.get_by_credentials(username, password) do
      {:error, user} ->
        conn
        |> put_status(403)
        |> put_view(EchoesWeb.LoginView)
        |> render("login.json", %{user: user})
      {:ok,    user} ->
        token = Guardian.encode_and_sign(user)
        conn
        |> put_view(EchoesWeb.LoginView)
        |> render("login.json", %{token: token})
    end
  end

end