defmodule Bordo.Config do
  @moduledoc """
  This module is responsible for all runtime config resolution.
  """

  use Vapor.Planner

  dotenv()

  config :auth0,
         env(
           host: "AUTH0_DOMAIN",
           client_id: "AUTH0_CLIENT_ID",
           client_secret: "AUTH0_CLIENT_SECRET",
           audience: "AUTH0_AUDIENCE"
         )

  config :cloudex,
         env(
           api_key: "CLOUDINARY_API_KEY",
           secret: "CLOUDINARY_API_SECRET",
           cloud_name: "CLOUDINARY_NAME"
         )

  config :web,
         env([
           {:port, "PORT", map: &String.to_integer/1, required: false},
           {:secret_key_base, "SECRET_KEY_BASE"}
         ])

  config :db,
         env([
           {:id, nil},
           {:url, "DATABASE_URL"},
           {:pool_size, "DB_POOL_SIZE", default: 10, map: &String.to_integer/1}
         ])
end
