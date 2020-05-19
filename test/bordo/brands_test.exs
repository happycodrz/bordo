defmodule Bordo.BrandsTest do
  use Bordo.DataCase

  alias Bordo.Brands

  describe "brands" do
    alias Bordo.Brands.Brand

    @valid_attrs %{name: "some name"}
    @update_attrs %{
      name: "some updated name"
    }
    @invalid_attrs %{name: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Brands.create_brand()

      brand
    end

    test "list_brands/0 returns all brands" do
      brand = fixture(:brand)

      assert Brands.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = fixture(:brand)
      assert Brands.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      user = fixture(:user)

      assert {:ok, %Brand{} = brand} =
               Brands.create_brand(@valid_attrs |> Enum.into(%{owner_id: user.id}))

      assert brand.name == "some name"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Brands.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = fixture(:brand)
      assert {:ok, %Brand{} = brand} = Brands.update_brand(brand, @update_attrs)
      assert brand.name == "some updated name"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = fixture(:brand)
      assert {:error, %Ecto.Changeset{}} = Brands.update_brand(brand, @invalid_attrs)
      assert brand == Brands.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = fixture(:brand)
      assert {:ok, %Brand{}} = Brands.delete_brand(brand)
      assert_raise Ecto.NoResultsError, fn -> Brands.get_brand!(brand.id) end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = fixture(:brand)
      assert %Ecto.Changeset{} = Brands.change_brand(brand)
    end
  end

  # describe "brand_users" do
  #   alias Bordo.Brands.BrandUser

  #   @valid_attrs %{}
  #   @update_attrs %{}
  #   @invalid_attrs %{}

  #   def user_brand_fixture(attrs \\ %{}) do
  #     {:ok, user_brand} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Brands.create_brand_user()

  #     user_brand
  #   end

  #   test "list_brand_users/0 returns all brand_users" do
  #     user_brand = user_brand_fixture()
  #     assert Brands.list_brand_users() == [user_brand]
  #   end

  #   test "get_user_brand!/1 returns the user_brand with given id" do
  #     user_brand = user_brand_fixture()
  #     assert Brands.get_user_brand!(user_brand.id) == user_brand
  #   end

  #   test "create_brand_user/1 with valid data creates a user_brand" do
  #     assert {:ok, %BrandUser{} = user_brand} = Brands.create_brand_user(@valid_attrs)
  #   end

  #   test "create_brand_user/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Brands.create_brand_user(@invalid_attrs)
  #   end

  #   test "update_user_brand/2 with valid data updates the user_brand" do
  #     user_brand = user_brand_fixture()

  #     assert {:ok, %BrandUser{} = user_brand} =
  #              Brands.update_user_brand(user_brand, @update_attrs)
  #   end

  #   test "update_user_brand/2 with invalid data returns error changeset" do
  #     user_brand = user_brand_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Brands.update_user_brand(user_brand, @invalid_attrs)
  #     assert user_brand == Brands.get_user_brand!(user_brand.id)
  #   end

  #   test "delete_user_brand/1 deletes the user_brand" do
  #     user_brand = user_brand_fixture()
  #     assert {:ok, %BrandUser{}} = Brands.delete_user_brand(user_brand)
  #     assert_raise Ecto.NoResultsError, fn -> Brands.get_user_brand!(user_brand.id) end
  #   end

  #   test "change_user_brand/1 returns a user_brand changeset" do
  #     user_brand = user_brand_fixture()
  #     assert %Ecto.Changeset{} = Brands.change_user_brand(user_brand)
  #   end
  # end

  # describe "brand_teams" do
  #   alias Bordo.Brands.BrandTeam

  #   @valid_attrs %{}
  #   @update_attrs %{}
  #   @invalid_attrs %{}

  #   def brand_team_fixture(attrs \\ %{}) do
  #     {:ok, brand_team} =
  #       attrs
  #       |> Enum.into(@valid_attrs)
  #       |> Brands.create_brand_team()

  #     brand_team
  #   end

  #   test "list_brand_teams/0 returns all brand_teams" do
  #     brand_team = brand_team_fixture()
  #     assert Brands.list_brand_teams() == [brand_team]
  #   end

  #   test "get_brand_team!/1 returns the brand_team with given id" do
  #     brand_team = brand_team_fixture()
  #     assert Brands.get_brand_team!(brand_team.id) == brand_team
  #   end

  #   test "create_brand_team/1 with valid data creates a brand_team" do
  #     assert {:ok, %BrandTeam{} = brand_team} = Brands.create_brand_team(@valid_attrs)
  #   end

  #   test "create_brand_team/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Brands.create_brand_team(@invalid_attrs)
  #   end

  #   test "update_brand_team/2 with valid data updates the brand_team" do
  #     brand_team = brand_team_fixture()

  #     assert {:ok, %BrandTeam{} = brand_team} =
  #              Brands.update_brand_team(brand_team, @update_attrs)
  #   end

  #   test "update_brand_team/2 with invalid data returns error changeset" do
  #     brand_team = brand_team_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Brands.update_brand_team(brand_team, @invalid_attrs)
  #     assert brand_team == Brands.get_brand_team!(brand_team.id)
  #   end

  #   test "delete_brand_team/1 deletes the brand_team" do
  #     brand_team = brand_team_fixture()
  #     assert {:ok, %BrandTeam{}} = Brands.delete_brand_team(brand_team)
  #     assert_raise Ecto.NoResultsError, fn -> Brands.get_brand_team!(brand_team.id) end
  #   end

  #   test "change_brand_team/1 returns a brand_team changeset" do
  #     brand_team = brand_team_fixture()
  #     assert %Ecto.Changeset{} = Brands.change_brand_team(brand_team)
  #   end
  # end
end
