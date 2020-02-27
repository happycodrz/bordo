alias Bordo.{Brands, Post, Users}
# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bordo.Repo.insert!(%Bordo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
users = [
  %{email: "kevin@bor.do"},
  %{email: "michael@bor.do"}
]

brands = [
  %{name: "Bordo"},
  %{name: "Fleetio"}
]

users
|> Enum.each(&Users.create_user(&1))

brands |> Enum.each(&Brands.create_brand(&1))
