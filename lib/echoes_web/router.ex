defmodule EchoesWeb.Router do
  use EchoesWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EchoesWeb do
    pipe_through :api

    post "/login", LoginController, :login
    post "/register", RegisterController, :register
    post "/upload", UploadController, :upload

  end
end
