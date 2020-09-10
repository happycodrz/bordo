defmodule Bordo.Fixtures do
  alias Bordo.{Brands, Channels, Posts, Teams, Users}
  alias Bordo.{PostVariants.PostVariant}

  alias Faker.{
    Blockchain.Bitcoin,
    Company,
    Internet,
    Team
  }

  def fixture(:user, assoc \\ [], attrs \\ %{}) do
    {:ok, user} =
      %{
        email: Internet.email(),
        password: Faker.random_bytes(12) |> Base.encode64(),
        auth0_id: Bitcoin.address()
      }
      |> Users.create_user()

    user |> Map.put(:password, nil)
  end

  def fixture(:team, assoc, attrs) do
    user = assoc[:user] || fixture(:user)

    {:ok, team} =
      attrs
      |> Enum.into(%{
        name: Team.name(),
        owner_id: user.id,
        stripe_customer_id: "cus_stripe_id",
        stripe_subscription_id: "sub_stripe_id"
      })
      |> Teams.create_team()

    team
  end

  def fixture(:brand, assoc, attrs) do
    team = assoc[:team] || fixture(:team)

    {:ok, brand} =
      attrs
      |> Enum.into(%{team_id: team.id, name: Company.name()})
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
    channel = assoc[:channel] || fixture(:channel)

    post_variants =
      assoc[:post_variants] || [%{channel_id: channel.id, content: "content", temp_id: "3"}]

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
