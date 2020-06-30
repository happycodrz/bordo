defmodule Bordo.TeamsTest do
  use Bordo.DataCase

  alias Bordo.Teams

  describe "teams" do
    alias Bordo.Teams.Team

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    @tag :focus
    test "list_teams/0 returns all teams" do
      team = fixture(:team)
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = fixture(:team)
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      user = fixture(:user)

      assert {:ok, %Team{} = team} =
               Teams.create_team(@valid_attrs |> Enum.into(%{owner_id: user.id}))

      assert team.name == "some name"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = fixture(:team)
      assert {:ok, %Team{} = team} = Teams.update_team(team, @update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = fixture(:team)
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = fixture(:team)
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = fixture(:team)
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end
end
