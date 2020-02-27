defmodule Bordo.TeamsTest do
  use Bordo.DataCase

  alias Bordo.Teams

  describe "teams" do
    alias Bordo.Teams.Team

    @valid_attrs %{name: "some name", uuid: "some uuid"}
    @update_attrs %{name: "some updated name", uuid: "some updated uuid"}
    @invalid_attrs %{name: nil, uuid: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_team()

      team
    end

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      assert {:ok, %Team{} = team} = Teams.create_team(@valid_attrs)
      assert team.name == "some name"
      assert team.uuid == "some uuid"
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Teams.update_team(team, @update_attrs)
      assert team.name == "some updated name"
      assert team.uuid == "some updated uuid"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "user_teams" do
    alias Bordo.Teams.UserTeam

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def user_team_fixture(attrs \\ %{}) do
      {:ok, user_team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teams.create_user_team()

      user_team
    end

    test "list_user_teams/0 returns all user_teams" do
      user_team = user_team_fixture()
      assert Teams.list_user_teams() == [user_team]
    end

    test "get_user_team!/1 returns the user_team with given id" do
      user_team = user_team_fixture()
      assert Teams.get_user_team!(user_team.id) == user_team
    end

    test "create_user_team/1 with valid data creates a user_team" do
      assert {:ok, %UserTeam{} = user_team} = Teams.create_user_team(@valid_attrs)
    end

    test "create_user_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_user_team(@invalid_attrs)
    end

    test "update_user_team/2 with valid data updates the user_team" do
      user_team = user_team_fixture()
      assert {:ok, %UserTeam{} = user_team} = Teams.update_user_team(user_team, @update_attrs)
    end

    test "update_user_team/2 with invalid data returns error changeset" do
      user_team = user_team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_user_team(user_team, @invalid_attrs)
      assert user_team == Teams.get_user_team!(user_team.id)
    end

    test "delete_user_team/1 deletes the user_team" do
      user_team = user_team_fixture()
      assert {:ok, %UserTeam{}} = Teams.delete_user_team(user_team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_user_team!(user_team.id) end
    end

    test "change_user_team/1 returns a user_team changeset" do
      user_team = user_team_fixture()
      assert %Ecto.Changeset{} = Teams.change_user_team(user_team)
    end
  end
end
