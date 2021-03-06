# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :bordo, BordoWeb.Endpoint,
  http: [:inet6, port: String.to_integer(System.get_env("PORT") || "4000")],
  check_origin: ["//*.bor.do"],
  secret_key_base: secret_key_base

config :bordo, Bordo.Repo,
  url: System.get_env("DATABASE_URL"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :bordo, BordoWeb.Endpoint,
  server: true,
  url: [
    host: System.get_env("RENDER_EXTERNAL_HOSTNAME") || "localhost",
    port: 443
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

# Enable appsignal, otherwise configured in config.exs
config :appsignal, :config, active: true
