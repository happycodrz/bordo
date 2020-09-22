defmodule EctoSlugs.Bordo.Brands.TitleSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug, always_change: true
  import Ecto.Query, only: [from: 2]

  import Ecto.Changeset

  alias Bordo.Brands.Brand
  alias Bordo.Repo

  def build_slug(sources, changeset) do
    team_id = get_change(changeset, :team_id)

    if name_changed?(changeset) && (is_nil(team_id) || slug_exists?(team_id)) do
      new_slug =
        sources <> "-" <> (4 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false))

      super(new_slug, changeset)
    else
      super(sources, changeset)
    end
  end

  def slug_exists?(team_id) do
    Repo.exists?(from b in Brand, where: b.team_id == ^team_id)
  end

  def name_changed?(changeset), do: changeset.changes |> Map.keys() |> Enum.member?(:name)
end
