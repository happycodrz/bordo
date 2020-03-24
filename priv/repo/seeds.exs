alias Bordo.{Brands, Posts, Teams, Users}

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

teams = [
  %{name: "Fleetio", owner_id: 1},
  %{name: "Bordo", owner_id: 2}
]

users = [
  %{email: "kevin@bor.do", auth0_id: "5e7a9a590cf8140c66c315b4"},
  %{email: "michael@bor.do"}
]

brands = [
  %{name: "Bordo", owner_id: 2},
  %{name: "Fleetio", owner_id: 1}
]

posts = [
  %{
    title: "Post for Bordo",
    brand_id: 1,
    user_id: 2,
    status: "published"
  },
  %{
    title: "Post for fleetio",
    brand_id: 2,
    user_id: 1,
    status: "published"
  }
]

# TODO: Refactor to use bang methods
# These are order-dependent
users
|> Enum.each(&Users.create_user(&1))

brands
|> Enum.each(&Brands.create_brand(&1))

teams
|> Enum.each(&Teams.create_team(&1))

posts
|> Enum.each(&Posts.create_post(&1))

user_brands = [
  %{
    brand_id: 2,
    user_id: 1
  },
  %{brand_id: 1, user_id: 2}
]

user_brands
|> Enum.each(&Brands.create_user_brand(&1))
