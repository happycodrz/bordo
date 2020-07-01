defmodule Bordo.Brands do
  @moduledoc """
  The Brands context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.{Brand, BrandUser}

  @doc """
  Returns the list of brands.

  ## Examples

      iex> list_brands()
      [%Brand{}, ...]

  """
  def list_brands do
    Repo.all(Brand)
  end

  def fuzzy_list_brands(name) do
    query = from b in Brand, where: ilike(b.name, ^"%#{name}%")
    Repo.all(query)
  end

  def list_brands_for_team(team_id) do
    query =
      from b in Brand,
        where: b.team_id == ^team_id

    Repo.all(query)
  end

  def list_brands_for_user(user_id) do
    query =
      from b in Brand,
        left_join: ub in BrandUser,
        on: b.id == ub.brand_id,
        distinct: b.id,
        where:
          b.owner_id == ^user_id or
            ub.user_id == ^user_id

    Repo.all(query)
  end

  @doc """
  Gets a single brand.

  Raises `Ecto.NoResultsError` if the Brand does not exist.

  ## Examples

      iex> get_brand!(123)
      %Brand{}

      iex> get_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand!(slug: slug), do: Repo.get_by!(Brand, slug: slug)
  def get_brand!(id), do: Repo.get!(Brand, id)

  @doc """
  Creates a brand.

  ## Examples

      iex> create_brand(%{field: value})
      {:ok, %Brand{}}

      iex> create_brand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand(attrs \\ %{}) do
    %Brand{}
    |> Brand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand.

  ## Examples

      iex> update_brand(brand, %{field: new_value})
      {:ok, %Brand{}}

      iex> update_brand(brand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand(%Brand{} = brand, attrs) do
    brand
    |> Brand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brand.

  ## Examples

      iex> delete_brand(brand)
      {:ok, %Brand{}}

      iex> delete_brand(brand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand(%Brand{} = brand) do
    Repo.delete(brand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand changes.

  ## Examples

      iex> change_brand(brand)
      %Ecto.Changeset{source: %Brand{}}

  """
  def change_brand(%Brand{} = brand) do
    Brand.changeset(brand, %{})
  end

  alias Bordo.Brands.BrandUser

  @doc """
  Returns the list of brand_users.

  ## Examples

      iex> list_brand_users()
      [%BrandUser{}, ...]

  """
  def list_brand_users do
    Repo.all(BrandUser)
  end

  @doc """
  Gets a single user_brand.

  Raises `Ecto.NoResultsError` if the User brand does not exist.

  ## Examples

      iex> get_user_brand!(123)
      %BrandUser{}

      iex> get_user_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_brand!(id), do: Repo.get!(BrandUser, id)

  @doc """
  Creates a user_brand.

  ## Examples

      iex> create_brand_user(%{field: value})
      {:ok, %BrandUser{}}

      iex> create_brand_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand_user(attrs \\ %{}) do
    %BrandUser{}
    |> BrandUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_brand.

  ## Examples

      iex> update_user_brand(user_brand, %{field: new_value})
      {:ok, %BrandUser{}}

      iex> update_user_brand(user_brand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_brand(%BrandUser{} = user_brand, attrs) do
    user_brand
    |> BrandUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_brand.

  ## Examples

      iex> delete_user_brand(user_brand)
      {:ok, %BrandUser{}}

      iex> delete_user_brand(user_brand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_brand(%BrandUser{} = user_brand) do
    Repo.delete(user_brand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_brand changes.

  ## Examples

      iex> change_user_brand(user_brand)
      %Ecto.Changeset{source: %BrandUser{}}

  """
  def change_user_brand(%BrandUser{} = user_brand) do
    BrandUser.changeset(user_brand, %{})
  end
end
