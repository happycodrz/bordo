use Mix.Config

# Configure your database
config :bordo, Bordo.Repo,
  username: "postgres",
  password: "postgres",
  database: "bordo_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bordo, BordoWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :mix_test_watch,
  clear: true

config :bordo, Oban, queues: false
