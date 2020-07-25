defmodule Bordo.PostVariants do
  @moduledoc """
  The PostVariants context.
  """

  import Ecto.Query, warn: false
  alias Bordo.Repo

  alias Bordo.PostVariants.PostVariant
  alias Bordo.PostVariants.PostVariantMedia

  @doc """
  Gets a single post_variant.
  Raises `Ecto.NoResultsError` if the Post variant does not exist.
  ## Examples
      iex> get_post_variant!(123)
      %PostVariant{}
      iex> get_post_variant!(456)
      ** (Ecto.NoResultsError)
  """
  def get_post_variant!(id), do: Repo.get!(PostVariant, id) |> Repo.preload(:media)
  def get_post_variant_media!(id), do: Repo.get!(PostVariantMedia, id)

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
    |> Repo.preload(:media)
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

  def delete_post_variant_media(%PostVariantMedia{} = post_variant_media) do
    Repo.delete(post_variant_media)
  end
end
