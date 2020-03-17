defmodule Bordo.Brands do
  @moduledoc """
  The Brands context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.Brands.{Brand, BrandTeam, UserBrand}
  alias Bordo.Teams.{Team}

  @doc """
  Returns the list of brands.

  ## Examples

      iex> list_brands()
      [%Brand{}, ...]

  """
  def list_brands do
    Repo.all(Brand)
  end

  def list_brands_for_team(team_id) do
    query =
      from t in Team,
        left_join: bt in BrandTeam,
        on: t.id == bt.brand_id,
        distinct: t.id,
        where: bt.team_id == ^team_id

    Repo.all(query)
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

  alias Bordo.Brands.BrandTeam

  @doc """
  Returns the list of brand_teams.

  ## Examples

      iex> list_brand_teams()
      [%BrandTeam{}, ...]

  """
  def list_brand_teams do
    Repo.all(BrandTeam)
  end

  @doc """
  Gets a single brand_team.

  Raises `Ecto.NoResultsError` if the Brand team does not exist.

  ## Examples

      iex> get_brand_team!(123)
      %BrandTeam{}

      iex> get_brand_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_brand_team!(id), do: Repo.get!(BrandTeam, id)

  @doc """
  Creates a brand_team.

  ## Examples

      iex> create_brand_team(%{field: value})
      {:ok, %BrandTeam{}}

      iex> create_brand_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_brand_team(attrs \\ %{}) do
    %BrandTeam{}
    |> BrandTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a brand_team.

  ## Examples

      iex> update_brand_team(brand_team, %{field: new_value})
      {:ok, %BrandTeam{}}

      iex> update_brand_team(brand_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_brand_team(%BrandTeam{} = brand_team, attrs) do
    brand_team
    |> BrandTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a brand_team.

  ## Examples

      iex> delete_brand_team(brand_team)
      {:ok, %BrandTeam{}}

      iex> delete_brand_team(brand_team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_brand_team(%BrandTeam{} = brand_team) do
    Repo.delete(brand_team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking brand_team changes.

  ## Examples

      iex> change_brand_team(brand_team)
      %Ecto.Changeset{source: %BrandTeam{}}

  """
  def change_brand_team(%BrandTeam{} = brand_team) do
    BrandTeam.changeset(brand_team, %{})
  end
end
