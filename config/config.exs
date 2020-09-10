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
  render_errors: [view: BordoWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Bordo.PubSub,
  live_view: [signing_salt: "1BmLGDPhgTI9L4/yAk7MNYRI1Majys+f"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Add support for microseconds at the DB level
# this avoids having to configure it on every migration file
config :bordo, Bordo.Repo, migration_timestamps: [type: :utc_datetime_usec]

config :bordo,
  auth0: %{
    url: %URI{
      host: System.get_env("AUTH0_DOMAIN"),
      port: 443,
      scheme: "https"
    },
    client_id: System.get_env("AUTH0_CLIENT_ID"),
    client_secret: System.get_env("AUTH0_CLIENT_SECRET"),
    audience: System.get_env("AUTH0_AUDIENCE"),
    scope: "read:all"
  }

# Setup Guardian with Auth0
config :bordo, Auth.Guardian,
  allowed_algos: ["HS256"],
  verify_module: Guardian.JWT,
  issuer: "bordo",
  verify_issuer: false,
  secret_key: System.get_env("AUTH0_SIGNING_SECRET")

config :cloudex,
  api_key: System.get_env("CLOUDINARY_API_KEY"),
  secret: System.get_env("CLOUDINARY_API_SECRET"),
  cloud_name: System.get_env("CLOUDINARY_NAME")

config :bordo, Oban,
  repo: Bordo.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 300}],
  queues: [default: 10, events: 50, media: 20]

config :appsignal, :config,
  active: false,
  name: "Bordo",
  push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY"),
  env: System.get_env("MIX_ENV", "dev"),
  revision: System.get_env("APP_REVISION"),
  ignore_actions: ["BordoWeb.HealthzController#index"]

config :auth0_ex,
  domain: System.get_env("AUTH0_DOMAIN"),
  mgmt_client_id: System.get_env("AUTH0_MGMT_CLIENT_ID"),
  mgmt_client_secret: System.get_env("AUTH0_MGMT_CLIENT_SECRET"),
  http_opts: []

config :stripity_stripe, api_key: System.get_env("STRIPE_SECRET")

config :bordo, :stripe, standard_price_id: "price_1HCuUsIa5ro1VoLo8QDydMJL"

####
# Integration configuration
####
config :facebook,
  app_id: System.get_env("FACEBOOK_APP_ID"),
  app_secret: System.get_env("FACEBOOK_APP_SECRET"),
  app_access_token: System.get_env("FACEBOOK_CLIENT_TOKEN"),
  graph_url: "https://graph.facebook.com",
  graph_video_url: "https://graph-video.facebook.com"

config :bordo,
  twitter_live: true,
  facebook_live: true,
  linkedin_live: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
