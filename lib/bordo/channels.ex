defmodule Bordo.Channels do
  @moduledoc """
  The Channels context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Channels.Channel

  alias Stripe.Subscription

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Repo.all(Channel)
  end

  @doc """
  Returns the list of channels by brand.

  ## Examples

      iex> list_channels(brand_id: brand_id)
      [%Channel{}, ...]

  """
  def list_channels(brand_id: brand_id) do
    query =
      from c in Channel,
        left_join: b in Brand,
        on: b.id == c.brand_id,
        where: b.id == ^brand_id

    Repo.all(query)
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """

  def get_channel!(brand_id: brand_id, network: network) do
    query =
      from c in Channel,
        left_join: b in Brand,
        on: b.id == c.brand_id,
        where:
          b.id ==
            ^brand_id and
            c.network == ^network

    query |> Repo.one()
  end

  @doc """
  Gets a single channel only for zapier based on token. This is a hack for "api auth".
  """
  def get_channel!(token: token) do
    query =
      from c in Channel,
        left_join: b in Brand,
        on: b.id == c.brand_id,
        where:
          c.token ==
            ^token and
            c.network == "zapier"

    query |> Repo.one()
  end

  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs \\ %{}) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
    |> increment_stripe_subscription()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    # Cleanup orphaned posts. This has the side-effect of potentially removing
    # more than just posts for the removed-channel.
    # This causes a bug which deleted _all_ posts, across other tenants.
    # We need to write a better query and test thoroughly
    # Posts.delete_posts_without_variants(channel.brand_id)
    Repo.delete(channel)
    |> decrement_stripe_subscription()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{source: %Channel{}}

  """
  def change_channel(%Channel{} = channel) do
    Channel.changeset(channel, %{})
  end

  def increment_stripe_subscription({:error, changeset}), do: {:error, changeset}

  def increment_stripe_subscription({:ok, channel}) do
    brand = Brands.get_brand!(channel.brand_id) |> Repo.preload([:team])
    {:ok, subscription} = Subscription.retrieve(brand.team.stripe_subscription_id)
    Subscription.update(brand.team.stripe_subscription_id, %{quantity: subscription.quantity + 1})

    {:ok, channel}
  end

  def decrement_stripe_subscription({:error, channel}), do: {:error, channel}

  def decrement_stripe_subscription({:ok, channel}) do
    brand = Brands.get_brand!(channel.brand_id) |> Repo.preload([:team])
    {:ok, subscription} = Subscription.retrieve(brand.team.stripe_subscription_id)
    Subscription.update(brand.team.stripe_subscription_id, %{quantity: subscription.quantity - 1})

    {:ok, channel}
  end
end
