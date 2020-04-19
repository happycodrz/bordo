defmodule Bordo.Posts do
  import Filtrex.Type.Config

  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Posts.Post
  alias Bordo.Brands.Brand

  def filter_options(:brand_index) do
    defconfig do
      datetime([:scheduled_for])
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(brand_id) do
    from(p in Post, where: p.brand_id == ^brand_id)
    |> Repo.all()
  end

  @doc """
  Returns the list of posts by brand slug.

  ## Examples

      iex> list_posts_for_brand(slug)
      [%User{}, ...]

  """
  def list_posts_for_brand(slug, filter) do
    base_query =
      from p in Post,
        left_join: b in Brand,
        on: b.id == p.brand_id,
        where: b.slug == ^slug

    Filtrex.query(base_query, filter)
    |> Bordo.Repo.all()
    |> Bordo.Repo.preload(:post_variants)
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
  def get_post!(id), do: Repo.get!(Post, id)

  def get_brand_post_by_slug!(brand_slug, slug) do
    query =
      from p in Post,
        left_join: b in Brand,
        on: b.id == p.brand_id,
        where: b.slug == ^brand_slug and p.slug == ^slug

    Repo.one!(query) |> Repo.preload(:post_variants)
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
  def get_scheduled_post!(id), do: Repo.get!(Post |> preload(post_variants: [:channel]), id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Repo.preload(:post_variants)
    |> Post.create_changeset(attrs)
    |> Repo.insert()
  end

  def create_and_schedule_post(attrs \\ %{}) do
    with {:ok, %Post{} = post} <- create_post(attrs) do
      case schedule_post(post) do
        {:ok, %Oban.Job{} = _job} ->
          {:ok, post}

        {:ok, %Post{} = post} ->
          {:ok, post}

        error ->
          {:error, error}
      end
    else
      {:error, err} ->
        {:error, err}
    end
  end

  def schedule_post(%Post{} = post) do
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
    |> Post.changeset(attrs)
    |> Repo.update()
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
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}

  """
  def change_post(%Post{} = post) do
    Post.changeset(post, %{})
  end
end
