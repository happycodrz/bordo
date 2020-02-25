defmodule Bordo.BrandsTest do
  use Bordo.DataCase

  alias Bordo.Brands

  describe "brands" do
    alias Bordo.Brands.Brand

    @valid_attrs %{icon_url: "some icon_url", name: "some name", uuid: "some uuid"}
    @update_attrs %{icon_url: "some updated icon_url", name: "some updated name", uuid: "some updated uuid"}
    @invalid_attrs %{icon_url: nil, name: nil, uuid: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Brands.create_brand()

      brand
    end

    test "list_brands/0 returns all brands" do
      brand = brand_fixture()
      assert Brands.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Brands.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Brands.create_brand(@valid_attrs)
      assert brand.icon_url == "some icon_url"
      assert brand.name == "some name"
      assert brand.uuid == "some uuid"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Brands.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{} = brand} = Brands.update_brand(brand, @update_attrs)
      assert brand.icon_url == "some updated icon_url"
      assert brand.name == "some updated name"
      assert brand.uuid == "some updated uuid"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Brands.update_brand(brand, @invalid_attrs)
      assert brand == Brands.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{}} = Brands.delete_brand(brand)
      assert_raise Ecto.NoResultsError, fn -> Brands.get_brand!(brand.id) end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Brands.change_brand(brand)
    end
  end
end
