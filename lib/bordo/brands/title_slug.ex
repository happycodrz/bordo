defmodule EctoSlugs.Bordo.Brands.TitleSlug do
  use EctoAutoslugField.Slug, from: :name, to: :slug
end
