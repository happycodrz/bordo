defmodule Bordo.Brands do
  @moduledoc """
  The Brands context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.{Brand, UserBrand}

  @doc """
  Returns the list of brands.

  ## Examples

      iex> list_brands()
      [%Brand{}, ...]

  """
  def list_brands do
    Repo.all(Brand)
  end

  def list_brands_for_user(user_id) do
    query =
      from b in Brand,
        left_join: ub in UserBrand,
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

  alias Bordo.Brands.UserBrand

  @doc """
  Returns the list of user_brands.

  ## Examples

      iex> list_user_brands()
      [%UserBrand{}, ...]

  """
  def list_user_brands do
    Repo.all(UserBrand)
  end

  @doc """
  Gets a single user_brand.

  Raises `Ecto.NoResultsError` if the User brand does not exist.

  ## Examples

      iex> get_user_brand!(123)
      %UserBrand{}

      iex> get_user_brand!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_brand!(id), do: Repo.get!(UserBrand, id)

  @doc """
  Creates a user_brand.

  ## Examples

      iex> create_user_brand(%{field: value})
      {:ok, %UserBrand{}}

      iex> create_user_brand(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_brand(attrs \\ %{}) do
    %UserBrand{}
    |> UserBrand.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_brand.

  ## Examples

      iex> update_user_brand(user_brand, %{field: new_value})
      {:ok, %UserBrand{}}

      iex> update_user_brand(user_brand, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_brand(%UserBrand{} = user_brand, attrs) do
    user_brand
    |> UserBrand.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_brand.

  ## Examples

      iex> delete_user_brand(user_brand)
      {:ok, %UserBrand{}}

      iex> delete_user_brand(user_brand)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_brand(%UserBrand{} = user_brand) do
    Repo.delete(user_brand)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_brand changes.

  ## Examples

      iex> change_user_brand(user_brand)
      %Ecto.Changeset{source: %UserBrand{}}

  """
  def change_user_brand(%UserBrand{} = user_brand) do
    UserBrand.changeset(user_brand, %{})
  end
end
