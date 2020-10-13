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

    test "list_brands/0 returns all brands" do
      brand = fixture(:brand)

      assert Brands.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = fixture(:brand)
      assert Brands.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Brands.create_brand(@valid_attrs)

      assert brand.name == "some name"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Brands.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = fixture(:brand, [], @valid_attrs)
      assert brand.slug == "some-name"
      assert {:ok, %Brand{} = brand} = Brands.update_brand(brand, @update_attrs)
      assert brand.name == "some updated name"
      assert brand.slug =~ "some-updated-name"
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
end
