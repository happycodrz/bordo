import Ecto.Changeset, only: [change: 2]

alias Bordo.{Brands, Repo, Teams, Users}

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

#
# Create users
#

users =
  [
    %Users.User{
      email: "kevin@bor.do",
      auth0_id: "5e7a9a590cf8140c66c315b4",
      first_name: "Kevin",
      last_name: "Brown"
    },
    %Users.User{
      email: "michael@bor.do",
      auth0_id: "5e519eaee234a20cfc54cb0f",
      first_name: "Michael",
      last_name: "Panik"
    }
  ]
  |> Enum.each(fn user -> Repo.insert!(user) end)

users = Users.list_users()
kevin = Enum.at(users, 0)
michael = Enum.at(users, 1)

#
# Create teams
#

[
  %Teams.Team{name: "Bordo", owner_id: michael.id},
  %Teams.Team{name: "Fleetio", owner_id: kevin.id}
]
|> Enum.each(fn team -> Repo.insert!(team) end)

teams = Teams.list_teams()
bordo = Enum.at(teams, 0)
fleetio = Enum.at(teams, 1)

Repo.update!(change(kevin, team_id: bordo.id))
Repo.update!(change(michael, team_id: bordo.id))

#
# Create brands
#

[
  %Brands.Brand{name: "Bordo", owner_id: michael.id, slug: "bordo"},
  %Brands.Brand{name: "Fleetio", owner_id: kevin.id, slug: "fleetio"}
]
|> Enum.each(fn brand -> Repo.insert!(brand) end)

brands = Brands.list_brands()
brand_bordo = Enum.at(brands, 0)
brand_fleetio = Enum.at(brands, 1)

#
# Link brands to users
#

[
  %Brands.BrandUser{
    brand_id: brand_bordo.id,
    user_id: kevin.id
  },
  %Brands.BrandUser{brand_id: brand_bordo.id, user_id: michael.id}
]
|> Enum.each(fn brand_user -> Repo.insert!(brand_user) end)
