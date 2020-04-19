defmodule Bordo.PostsTest do
  use Bordo.DataCase

  alias Bordo.Posts

  describe "posts" do
    alias Bordo.Posts.Post

    @valid_attrs %{status: "some status", title: "some title"}
    @update_attrs %{status: "some updated status", title: "some updated title"}
    @invalid_attrs %{status: nil, title: nil}

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_post()

      post
    end

    setup do
      {:ok, user} = Bordo.Users.create_user(%{email: "xx", auth0_id: "1234"})

      {:ok, brand} =
        Bordo.Brands.create_brand(%{name: "test brand", owner_id: user.id, slug: "test-brand"})

      {:ok, brand: brand, user: user}
    end

    test "list_posts_for_brand/2 returns posts for brand", %{brand: brand, user: user} do
      post = post_fixture(%{brand_id: brand.id, user_id: user.id})
      config = Bordo.Posts.filter_options(:brand_index)
      {:ok, filters} = Filtrex.parse_params(config, %{})

      assert Posts.list_posts_for_brand(brand.slug, filters) == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs)
      assert post.title == "some title"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
