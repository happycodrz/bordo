defmodule Bordo.Fixtures do
  alias Bordo.{Channels, Posts, Teams, Users}

  def fixture(:user) do
    {:ok, user} =
      %{
        email: Faker.Internet.email(),
        auth0_id: Faker.Blockchain.Bitcoin.address()
      }
      |> Users.create_user()

    user
  end

  def fixture(:team, assoc \\ []) do
    user = assoc[:user] || fixture(:user)

    {:ok, team} =
      %{}
      |> Enum.into(%{name: Faker.Team.name(), owner_id: user.id})
      |> Teams.create_team()

    team
  end

  def fixture(:brand, assoc) do
    user = assoc[:user] || fixture(:user)

    {:ok, brand} = Bordo.Brands.create_brand(%{name: Faker.Company.name(), owner_id: user.id})
    brand
  end

  def fixture(:channel, assoc) do
    brand = assoc[:brand] || fixture(:brand)

    {:ok, channel} =
      Channels.create_channel(%{
        brand_id: brand.id,
        network: "twitter",
        token: "123",
        token_secret: "456"
      })

    channel
  end

  def fixture(:post, assoc) do
    user = assoc[:user] || fixture(:user)
    brand = assoc[:brand] || fixture(:brand)
    post_variants = assoc[:post_variants] || []

    {:ok, post} =
      Posts.create_post(%{
        user_id: user.id,
        brand_id: brand.id,
        status: "published",
        title: "title",
        post_variants: post_variants
      })

    post
  end
end
