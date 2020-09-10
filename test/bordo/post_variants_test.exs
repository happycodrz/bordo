defmodule Bordo.PostVariantsTest do
  use Bordo.DataCase

  alias Bordo.PostVariants

  describe "post_variants" do
    alias Bordo.PostVariants.PostVariant

    @update_attrs %{content: "updated post content"}
    @invalid_attrs %{status: "invalid status"}

    def post_variant_fixture() do
      brand = fixture(:brand)
      channel = fixture(:channel, brand: brand)

      post_variant =
        fixture(:post,
          brand: brand,
          post_variants: [
            %{
              content: "post content",
              channel_id: channel.id
            }
          ]
        )
        |> Map.get(:post_variants)
        |> Enum.at(0)

      post_variant
    end

    test "update_post_variant/2 with valid data updates the post_variant" do
      post_variant = post_variant_fixture()

      assert {:ok, %PostVariant{} = post_variant} =
               PostVariants.update_post_variant(post_variant, @update_attrs)

      assert post_variant.content == "updated post content"
    end

    @tag :skip
    test "update_post_variant/2 with invalid data returns error changeset" do
      post_variant = post_variant_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PostVariants.update_post_variant(post_variant, @invalid_attrs)

      assert post_variant == PostVariants.get_post_variant!(post_variant.id)
    end

    @tag :focus
    test "delete_post_variant/1 deletes the post_variant" do
      post_variant = post_variant_fixture()
      assert {:ok, %PostVariant{}} = PostVariants.delete_post_variant(post_variant)
      assert_raise Ecto.NoResultsError, fn -> PostVariants.get_post_variant!(post_variant.id) end
    end
  end
end
