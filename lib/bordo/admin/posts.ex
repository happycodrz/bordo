defmodule Bordo.Admin.Posts do
  @moduledoc """
  The Posts context.
  """
  import Filtrex.Type.Config
  import Ecto.Query, warn: false
  alias Bordo.Repo

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
      text([:brand_id])
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

  def list_posts(post_filter, post_variants_filter) do
    post_query =
      Post
      |> Filtrex.query(post_filter)

    post_variant_query =
      PostVariant
      |> Filtrex.query(post_variants_filter)

    base_query = from(p in post_query, join: pv in ^post_variant_query, on: p.id == pv.post_id)

    base_query
    |> Bordo.Repo.all()
    |> Repo.preload([:brand, post_variants: [:channel, :media]])
  end
end
