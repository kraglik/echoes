defmodule Echoes.Repo do
  use Ecto.Repo,
    otp_app: :echoes,
    adapter: Ecto.Adapters.Postgres
end
