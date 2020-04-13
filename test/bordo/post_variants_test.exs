defmodule Bordo.PostVariantsTest do
  use Bordo.DataCase

  alias Bordo.PostVariants

  describe "post_variants" do
    alias Bordo.PostVariants.PostVariant

    @valid_attrs %{content: "post content"}
    @update_attrs %{content: "updated post content"}
    @invalid_attrs %{status: "invalid status"}

    def post_variant_fixture(attrs \\ %{}) do
      {:ok, post_variant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PostVariants.create_post_variant()

      post_variant
    end

    test "list_post_variants/0 returns all post_variants" do
      post_variant = post_variant_fixture()
      assert PostVariants.list_post_variants() == [post_variant]
    end

    test "get_post_variant!/1 returns the post_variant with given id" do
      post_variant = post_variant_fixture()
      assert PostVariants.get_post_variant!(post_variant.id) == post_variant
    end

    test "create_post_variant/1 with valid data creates a post_variant" do
      assert {:ok, %PostVariant{} = post_variant} = PostVariants.create_post_variant(@valid_attrs)
      assert post_variant.content == "post content"
    end

    test "create_post_variant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PostVariants.create_post_variant(@invalid_attrs)
    end

    test "update_post_variant/2 with valid data updates the post_variant" do
      post_variant = post_variant_fixture()

      assert {:ok, %PostVariant{} = post_variant} =
               PostVariants.update_post_variant(post_variant, @update_attrs)

      assert post_variant.content == "updated post content"
    end

    test "update_post_variant/2 with invalid data returns error changeset" do
      post_variant = post_variant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PostVariants.update_post_variant(post_variant, @invalid_attrs)

      assert post_variant == PostVariants.get_post_variant!(post_variant.id)
    end

    test "delete_post_variant/1 deletes the post_variant" do
      post_variant = post_variant_fixture()
      assert {:ok, %PostVariant{}} = PostVariants.delete_post_variant(post_variant)
      assert_raise Ecto.NoResultsError, fn -> PostVariants.get_post_variant!(post_variant.id) end
    end

    test "change_post_variant/1 returns a post_variant changeset" do
      post_variant = post_variant_fixture()
      assert %Ecto.Changeset{} = PostVariants.change_post_variant(post_variant)
    end
  end
end
