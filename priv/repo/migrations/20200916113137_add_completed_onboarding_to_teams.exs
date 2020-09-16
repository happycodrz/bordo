defmodule Bordo.Repo.Migrations.AddCompletedOnboardingToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add(:completed_onboarding, :boolean, default: false)
    end
  end
end
