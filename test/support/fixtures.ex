defmodule Bordo.Fixtures do
  alias Bordo.{Brands, Channels, Posts, Teams, Users}

  def fixture(:user, assoc \\ [], attrs \\ %{}) do
    {:ok, user} =
      %{
        email: Faker.Internet.email(),
        password: Faker.random_bytes(12) |> Base.encode64(),
        auth0_id: Faker.Blockchain.Bitcoin.address()
      }
      |> Users.create_user()

    user |> Map.put(:password, nil)
  end

  def fixture(:team, assoc, attrs) do
    user = assoc[:user] || fixture(:user)

    {:ok, team} =
      %{}
      |> Enum.into(%{name: Faker.Team.name(), owner_id: user.id})
      |> Teams.create_team()

    team
  end

  def fixture(:brand, assoc, attrs) do
    user = assoc[:user] || fixture(:user)

    {:ok, brand} =
      attrs
      |> Enum.into(%{name: Faker.Company.name(), owner_id: user.id})
      |> Brands.create_brand()

    brand
  end

  def fixture(:channel, assoc, attrs) do
    brand = assoc[:brand] || fixture(:brand)

    {:ok, channel} =
      Channels.create_channel(%{
        brand_id: brand.id,
        network: "twitter",
        token: "123",
        token_secret: "456",
        resource_info: %{}
      })

    channel
  end

  def fixture(:post, assoc, attrs) do
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
