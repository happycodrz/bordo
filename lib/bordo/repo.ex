defmodule Bordo.Repo do
  use Ecto.Repo,
    otp_app: :bordo,
    adapter: Ecto.Adapters.Postgres
end
