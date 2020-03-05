# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bordo,
  ecto_repos: [Bordo.Repo]

# Configures the endpoint
config :bordo, BordoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "d6e5ngspqBijQHX/VSd2HX66Jop3fO9FIyfu7XglCVBf2moc7Zw0eDsynS9rQSFq",
  render_errors: [view: BordoWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Bordo.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Add support for microseconds at the DB level
# this avoids having to configure it on every migration file
config :bordo, Bordo.Repo, migration_timestamps: [type: :utc_datetime_usec]

config :ex_aws,
  json_codec: Jason,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
