defmodule Bordo.Admin.Posts do
  @moduledoc """
  The Posts context.
  """
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.Brand
  alias Bordo.Posts.Post
  alias Bordo.PostVariants.PostVariant
  @topic inspect(Bordo.Posts)

  def subscribe do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic)
    # TODO subscribe to admin module too?
  end

  def subscribe(post_id) do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic <> "#{post_id}")
    # TODO subscribe to admin module too?
  end

  def filter_options(:admin_posts) do
    defconfig do
      text([:brand_name])
    end
  end

  def filter_options(:admin_brands) do
    defconfig do
      text([:name])
    end
  end

  def filter_options(:admin_post_variants) do
    defconfig do
      text([:status])
    end
  end

  @doc """
  Returns the list of posts by brand.

  ## Examples

      iex> list_posts(slug)
      [%User{}, ...]

  """

  def list_posts(brand_filter, post_variants_filter) do
    brand_query =
      Brand
      |> Filtrex.query(brand_filter)

    post_variant_query =
      PostVariant
      |> Filtrex.query(post_variants_filter)

    base_query =
      from(p in Post,
        join: pv in ^post_variant_query,
        on: p.id == pv.post_id,
        join: b in ^brand_query,
        on: b.id == p.brand_id
      )

    base_query
    |> Repo.all()
    |> Repo.preload([:brand, post_variants: [:channel, :media]])
  end

  def get_post!(id),
    do: Repo.get!(Post, id) |> Repo.preload([:brand, :user, post_variants: [:channel, :media]])
end
