defmodule EctoSlugs.Bordo.Posts.NumberableSlug do
  use EctoAutoslugField.Slug, to: :slug
  import Ecto.Query, warn: false
  import Ecto.Changeset, warn: false

  alias Bordo.Repo
  alias Bordo.Posts.Post

  def get_sources(changeset, _opts) do
    # This function is used to get sources to build slug from:
    changeset
    |> get_brand_id
    |> get_last_post
    |> maybe_increment_slug
  end

  defp get_brand_id(changeset) do
    changeset.changes.brand_id
  end

  defp get_last_post(brand_id) do
    Repo.one(from p in Post, where: p.brand_id == ^brand_id, order_by: [desc: p.slug], limit: 1)
  end

  defp maybe_increment_slug(post) do
    if is_nil(post) do
      ["1"]
    else
      [Integer.to_string(post.slug + 1)]
    end
  end
end
