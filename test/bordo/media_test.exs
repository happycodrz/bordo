defmodule Bordo.MediaTest do
  use Bordo.DataCase

  alias Bordo.Media

  describe "images" do
    alias Bordo.Media.Images

    @valid_attrs %{name: "some name", s3_object_name: "some s3_object_name", s3_path: "some s3_path"}
    @update_attrs %{name: "some updated name", s3_object_name: "some updated s3_object_name", s3_path: "some updated s3_path"}
    @invalid_attrs %{name: nil, s3_object_name: nil, s3_path: nil}

    def images_fixture(attrs \\ %{}) do
      {:ok, images} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_images()

      images
    end

    test "list_images/0 returns all images" do
      images = images_fixture()
      assert Media.list_images() == [images]
    end

    test "get_images!/1 returns the images with given id" do
      images = images_fixture()
      assert Media.get_images!(images.id) == images
    end

    test "create_images/1 with valid data creates a images" do
      assert {:ok, %Images{} = images} = Media.create_images(@valid_attrs)
      assert images.name == "some name"
      assert images.s3_object_name == "some s3_object_name"
      assert images.s3_path == "some s3_path"
    end

    test "create_images/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_images(@invalid_attrs)
    end

    test "update_images/2 with valid data updates the images" do
      images = images_fixture()
      assert {:ok, %Images{} = images} = Media.update_images(images, @update_attrs)
      assert images.name == "some updated name"
      assert images.s3_object_name == "some updated s3_object_name"
      assert images.s3_path == "some updated s3_path"
    end

    test "update_images/2 with invalid data returns error changeset" do
      images = images_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_images(images, @invalid_attrs)
      assert images == Media.get_images!(images.id)
    end

    test "delete_images/1 deletes the images" do
      images = images_fixture()
      assert {:ok, %Images{}} = Media.delete_images(images)
      assert_raise Ecto.NoResultsError, fn -> Media.get_images!(images.id) end
    end

    test "change_images/1 returns a images changeset" do
      images = images_fixture()
      assert %Ecto.Changeset{} = Media.change_images(images)
    end
  end

  describe "images" do
    alias Bordo.Media.Image

    @valid_attrs %{name: "some name", s3_object_name: "some s3_object_name", s3_path: "some s3_path"}
    @update_attrs %{name: "some updated name", s3_object_name: "some updated s3_object_name", s3_path: "some updated s3_path"}
    @invalid_attrs %{name: nil, s3_object_name: nil, s3_path: nil}

    def image_fixture(attrs \\ %{}) do
      {:ok, image} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Media.create_image()

      image
    end

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Media.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Media.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      assert {:ok, %Image{} = image} = Media.create_image(@valid_attrs)
      assert image.name == "some name"
      assert image.s3_object_name == "some s3_object_name"
      assert image.s3_path == "some s3_path"
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      assert {:ok, %Image{} = image} = Media.update_image(image, @update_attrs)
      assert image.name == "some updated name"
      assert image.s3_object_name == "some updated s3_object_name"
      assert image.s3_path == "some updated s3_path"
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_image(image, @invalid_attrs)
      assert image == Media.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Media.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Media.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Media.change_image(image)
    end
  end
end
