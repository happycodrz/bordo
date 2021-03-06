defmodule Bordo.Posts do
  import Filtrex.Type.Config

  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.Brand
  alias Bordo.Posts.Post
  alias Bordo.PostVariants.PostVariant

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic)
  end

  def subscribe(post_id) do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic <> "#{post_id}")
  end

  def filter_options(:brand_index) do
    defconfig do
      datetime([:scheduled_for])
    end
  end

  @doc """
  Returns the list of posts by brand.

  ## Examples

      iex> list_posts(slug)
      [%User{}, ...]

  """
  def list_posts(brand_id, filter) do
    base_query =
      from p in Post,
        left_join: b in Brand,
        on: b.id == p.brand_id,
        where: b.id == ^brand_id

    Filtrex.query(base_query, filter)
    |> Repo.all()
    |> Repo.preload(post_variants: [:channel, :media, :post_variant_media])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id),
    do:
      Repo.get!(Post, id) |> Repo.preload(post_variants: [:channel, :post_variant_media, :media])

  def get_brand_post!(id, brand_id) do
    query =
      from p in Post,
        left_join: b in Brand,
        on: b.id == p.brand_id,
        where: b.id == ^brand_id and p.id == ^id

    Repo.one!(query) |> Repo.preload(post_variants: :channel)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_scheduled_post!(123)
      %Post{}

      iex> get_scheduled_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scheduled_post!(id),
    do:
      Repo.get!(
        Post |> preload(post_variants: [:post_variant_media, :media, channel: [:webhooks]]),
        id
      )

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    # Need to insert and then get the post so media will be preloaded
    # maybe this can be done in one swoop, but I'm not sure how right now

    case %Post{}
         |> Repo.preload(post_variants: [:channel, :post_variant_media])
         |> Post.create_changeset(attrs)
         |> Repo.insert()
         |> notify_subscribers([:post, :created]) do
      {:ok, post} ->
        {:ok, get_post!(post.id)}

      changeset ->
        changeset
    end
  end

  def create_and_schedule_post(attrs \\ %{}) do
    with {:ok, %Post{} = post} <- create_post(attrs),
         {:ok, %Oban.Job{}} <- schedule_post(post) do
      {:ok, post}
    else
      {:error, err} ->
        {:error, err}
    end
  end

  def update_and_schedule_post(post, attrs \\ %{}) do
    # TODO: clear out old schedule posts
    clear_queued_post(post)

    with {:ok, %Post{} = post} <- update_post(post, attrs),
         {:ok, %Oban.Job{}} <- schedule_post(post) do
      {:ok, post}
    else
      {:error, err} ->
        {:error, err}
    end
  end

  defp schedule_post(%Post{} = post) do
    %{"post_id" => post.id}
    |> Bordo.Workers.PostScheduler.new(scheduled_at: post.scheduled_for)
    |> Oban.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Repo.preload(post_variants: [:media])
    |> Post.update_changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:post, :updated])
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    clear_queued_post(post)
    Repo.delete(post)
  end

  @doc """
  This is a cleanup function. The intent is to find posts that have had their
  channels removed. Removing a channel will delete all post-variants, thereby making
  the post a sort-of orphan.
  """
  def delete_posts_without_variants(brand_id) do
    orphans =
      Post
      |> join(:left, [p], p in assoc(p, :post_variants))
      |> where([p], p.brand_id == ^brand_id)
      |> where([p, pv], is_nil(pv.id))

    Post
    |> join(:inner, [p], p in subquery(orphans))
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post, changes \\ %{}) do
    Post.update_changeset(post, changes)
  end

  def change_post_variant(%PostVariant{} = post_variant, changes \\ %{}) do
    PostVariant.changeset(post_variant, changes)
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}

  defp clear_queued_post(post) do
    job = Repo.get_by(Oban.Job, args: %{"post_id" => post.id})

    if is_nil(job) do
    else
      Repo.delete(job)
    end
  end
end
