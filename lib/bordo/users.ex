defmodule Bordo.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.{Brand, BrandUser}
  alias Bordo.Users.User
  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic)
  end

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(Bordo.PubSub, @topic <> "#{user_id}")
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    User |> order_by(desc: :inserted_at) |> Repo.all() |> Bordo.Repo.preload(:team)
  end

  @doc """
  Returns the list of users joined with a brand by slug.

  ## Examples

      iex> list_users_for_brand(slug)
      [%User{}, ...]

  """
  def list_users_for_brand(brand_id) do
    query =
      from u in User,
        left_join: ub in BrandUser,
        on: u.id == ub.user_id,
        left_join: b in Brand,
        on: b.id == ub.brand_id,
        distinct: u.id,
        where: b.id == ^brand_id

    Repo.all(query)
  end

  @doc """
  Returns the list of users joined with a brand by team_id.

  ## Examples

      iex> list_users_for_brand(team_id)
      [%User{}, ...]

  """
  def list_users_for_team(team_id) do
    query =
      from u in User,
        where: u.team_id == ^team_id

    Repo.all(query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> notify_subscribers([:user, :created])
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand_user(attrs \\ %{}) do
    %BrandUser{}
    |> BrandUser.changeset(attrs)
    |> Repo.insert()
  end

  def find_or_create(attrs) do
    {:ok, user} =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert(on_conflict: :nothing)

    if is_nil(user.id) do
      {:ok, user}
    else
      {:ok, Repo.one(from u in User, where: u.id == ^user.id)}
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> notify_subscribers([:user, :updated])
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(user, attrs \\ %{}) do
    User.changeset(user, %{})
  end

  defp notify_subscribers({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic, {__MODULE__, event, result})
    Phoenix.PubSub.broadcast(Bordo.PubSub, @topic <> "#{result.id}", {__MODULE__, event, result})
    {:ok, result}
  end

  defp notify_subscribers({:error, reason}, _event), do: {:error, reason}
end
