defmodule EctoSlugs.Bordo.Posts.NumberableSlug do
  use EctoAutoslugField.Slug, to: :slug
  import Ecto.Query, warn: false
  import Ecto.Changeset, warn: false

  alias Bordo.Repo
  alias Bordo.Posts.Post

  # @behaviour EctoSlugs.Bordo.Posts.TitleSlug.Type
  def cast, do: 1

  def get_sources(changeset, _opts) do
    # # This function is used to get sources to build slug from:
    brand_id = changeset.changes.brand_id

    last_post =
      Repo.one(from p in Post, where: p.brand_id == ^brand_id, order_by: [desc: p.slug], limit: 1)

    if is_nil(last_post) do
      ["1"]
    else
      [Integer.to_string(last_post.slug + 1)]
    end
  end
end
