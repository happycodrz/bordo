defmodule Bordo.PostVariants do
  @moduledoc """
  The PostVariants context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.PostVariants.PostVariant

  @doc """
  Returns the list of post_variants.

  ## Examples

      iex> list_post_variants()
      [%PostVariant{}, ...]

  """
  def list_post_variants do
    Repo.all(PostVariant)
  end

  @doc """
  Gets a single post_variant.

  Raises `Ecto.NoResultsError` if the Post variant does not exist.

  ## Examples

      iex> get_post_variant!(123)
      %PostVariant{}

      iex> get_post_variant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post_variant!(id), do: Repo.get!(PostVariant, id)

  @doc """
  Creates a post_variant.

  ## Examples

      iex> create_post_variant(%{field: value})
      {:ok, %PostVariant{}}

      iex> create_post_variant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post_variant(attrs \\ %{}) do
    %PostVariant{}
    |> PostVariant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post_variant.

  ## Examples

      iex> update_post_variant(post_variant, %{field: new_value})
      {:ok, %PostVariant{}}

      iex> update_post_variant(post_variant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post_variant(%PostVariant{} = post_variant, attrs) do
    post_variant
    |> PostVariant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post_variant.

  ## Examples

      iex> delete_post_variant(post_variant)
      {:ok, %PostVariant{}}

      iex> delete_post_variant(post_variant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post_variant(%PostVariant{} = post_variant) do
    Repo.delete(post_variant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post_variant changes.

  ## Examples

      iex> change_post_variant(post_variant)
      %Ecto.Changeset{source: %PostVariant{}}

  """
  def change_post_variant(%PostVariant{} = post_variant) do
    PostVariant.changeset(post_variant, %{})
  end
end
