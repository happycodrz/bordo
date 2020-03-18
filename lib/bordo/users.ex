defmodule Bordo.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.{Brand, UserBrand}
  alias Bordo.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users joined with a brand by uuid.

  ## Examples

      iex> list_users_for_brand(brand_uuid)
      [%User{}, ...]

  """
  def list_users_for_brand(uuid: brand_uuid) do
    query =
      from u in User,
        left_join: ub in UserBrand,
        on: u.id == ub.user_id,
        left_join: b in Brand,
        on: b.id == ub.brand_id,
        distinct: u.id,
        where: b.uuid == ^brand_uuid

    Repo.all(query)
  end

  @doc """
  Returns the list of users joined with a brand by uuid.

  ## Examples

      iex> list_users_for_brand(brand_uuid)
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
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
