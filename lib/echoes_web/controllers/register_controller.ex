defmodule EchoesWeb.RegisterController do
  use EchoesWeb, :controller

  alias Echoes.{Repo, User, Guardian}
  alias Echoes.Guardian

  def register(
        conn,
        %{"email" => email, "name" => name, "password" => password, "username" => username}
      ) do

    case User.check_errors(email, username) do
      [] ->
        user = User.create(name, email, username, password)
        case user do
          nil ->
            conn
              |> put_status(500)
              |> render("register_failed.json", %{error: "failed"})

          user ->
            conn
            |> render(
                 "registered.json",
                 %{user: user, token: Guardian.encode_and_sign(user)}
               )
        end
      errors ->
        conn
          |> put_status(400)
          |> render("register_failed.json", %{error: errors})
    end


  end

end