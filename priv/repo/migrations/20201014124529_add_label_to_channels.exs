defmodule Bordo.Repo.Migrations.AddLabelToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add(:label, :string)
    end
  end
end
