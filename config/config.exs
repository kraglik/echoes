# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :echoes,
  ecto_repos: [Echoes.Repo]

# Configures the endpoint
config :echoes, EchoesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "9rzGk7CSC3vahMEo9/ri48clQN3o1cBinGUwwrZ+aomnx3kT4v24l2KssmzhZ3FQ",
  render_errors: [view: EchoesWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Echoes.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :echoes, Echoes.Guardian,
       issuer: "echoes",
       secret_key: "JWT_SECRET_KEY",
       ttl: {365, :day}

config :ex_aws,
       json_codec: Jason,
       access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
       secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
       region: "eu-north-1"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
