defmodule Bordo.Admin.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Posts.Post
  @topic inspect(Bordo.Posts)

  def subscribe do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic)
    # TODO subscribe to admin module too?
  end

  def subscribe(post_id) do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic <> "#{post_id}")
    # TODO subscribe to admin module too?
  end

  @doc """
  Returns the list of posts by brand.

  ## Examples

      iex> list_posts(slug)
      [%User{}, ...]

  """
  def list_posts do
    base_query = from(p in Post)

    base_query
    |> Repo.all()
    |> Repo.preload([:brand, post_variants: [:channel, :media]])
  end
end
