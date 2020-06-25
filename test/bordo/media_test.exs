defmodule Bordo.MediaTest do
  use Bordo.DataCase

  alias Bordo.Media, as: MediaResource

  describe "media" do
    alias Bordo.Media.Media

    @valid_attrs %{
      title: "some title",
      public_id: Ecto.UUID.generate(),
      url: "http://bor.do/media/123.png",
      thumbnail_url: "http://bor.do/media/123.png",
      bytes: 1024,
      width: 7,
      height: 7,
      resource_type: "image"
    }
    @update_attrs %{
      title: "some updated name"
    }
    @invalid_attrs %{title: nil}

    def media_fixture(attrs \\ %{}) do
      brand = fixture(:brand)

      {:ok, media} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Enum.into(%{brand_id: brand.id})
        |> MediaResource.create_media()

      media
    end

    test "list_media/0 returns all media" do
      media = media_fixture()
      assert MediaResource.list_media() == [media]
    end

    test "get_media!/1 returns the media with given id" do
      media = media_fixture()
      assert MediaResource.get_media!(media.id) == media
    end

    test "create_media/1 with valid data creates a media" do
      brand = fixture(:brand)

      assert {:ok, %Media{} = media} =
               MediaResource.create_media(@valid_attrs |> Enum.into(%{brand_id: brand.id}))

      assert media.title == "some title"
    end

    test "create_media/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MediaResource.create_media(@invalid_attrs)
    end

    test "update_media/2 with valid data updates the media" do
      media = media_fixture()
      assert {:ok, %Media{} = media} = MediaResource.update_media(media, @update_attrs)
      assert media.title == "some updated name"
    end

    test "update_media/2 with invalid data returns error changeset" do
      media = media_fixture()
      assert {:error, %Ecto.Changeset{}} = MediaResource.update_media(media, @invalid_attrs)
      assert media == MediaResource.get_media!(media.id)
    end

    test "delete_media/1 deletes the media" do
      media = media_fixture()
      assert {:ok, %Media{}} = MediaResource.delete_media(media)
      assert_raise Ecto.NoResultsError, fn -> MediaResource.get_media!(media.id) end
    end

    test "change_media/1 returns a media changeset" do
      media = media_fixture()
      assert %Ecto.Changeset{} = MediaResource.change_media(media)
    end
  end
end
