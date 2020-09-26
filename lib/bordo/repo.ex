defmodule Bordo.Repo do
  use Ecto.Repo,
    otp_app: :bordo,
    adapter: Ecto.Adapters.Postgres,
    pool_size: 10

  use Scrivener, page_size: 10
end
