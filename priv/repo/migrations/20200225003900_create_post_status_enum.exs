defmodule Bordo.Repo.Migrations.CreatePostStatusEnum do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE post_status AS ENUM ('draft', 'published', 'scheduled', 'failed')",
      "DROP TYPE post_status IF EXISTS"
    )
  end
end
