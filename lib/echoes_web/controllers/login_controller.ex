defmodule EchoesWeb.LoginController do
  use EchoesWeb, :controller

  alias Echoes.{Repo, User, Guardian}
  alias Echoes.Guardian

  def login(conn, %{"username" => username, "password" => password}) do
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

  def login(conn, _params) do
    conn
      |> put_status(400)
      |> render("login.json", correct: false)
  end

end