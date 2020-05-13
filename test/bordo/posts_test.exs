defmodule Bordo.PostsTest do
  use Bordo.DataCase
  use Oban.Testing, repo: Bordo.Repo

  alias Bordo.Posts

  describe "posts" do
    alias Bordo.Posts.Post

    @valid_attrs %{status: "some status", title: "some title"}
    @update_attrs %{status: "some updated status", title: "some updated title"}
    @invalid_attrs %{status: nil, title: nil}

    test "list_posts_for_brand/2 returns posts for brand" do
      brand = fixture(:brand)
      post = fixture(:post, brand: brand)
      config = Bordo.Posts.filter_options(:brand_index)
      {:ok, filters} = Filtrex.parse_params(config, %{})

      assert Posts.list_posts(brand.id, filters) == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = fixture(:post)
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = fixture(:user)
      brand = fixture(:brand)

      assert {:ok, %Post{} = post} =
               Posts.create_post(
                 @valid_attrs
                 |> Enum.into(%{brand_id: brand.id, user_id: user.id})
               )

      assert post.title == "some title"
    end

    test "create_and_schedule_post/1" do
      user = fixture(:user)
      brand = fixture(:brand)

      assert {:ok, %Post{} = post} =
               Posts.create_and_schedule_post(
                 @valid_attrs
                 |> Enum.into(%{brand_id: brand.id, user_id: user.id})
               )

      assert_enqueued(worker: Bordo.Workers.PostScheduler, args: %{"post_id" => post.id})
    end

    test "create_post/1 with invalid data returns error changeset" do
      brand = fixture(:brand)

      assert {:error, %Ecto.Changeset{}} =
               Posts.create_post(@invalid_attrs |> Enum.into(%{brand_id: brand.id}))
    end

    test "update_post/2 with valid data updates the post" do
      post = fixture(:post)
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = fixture(:post)
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = fixture(:post)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = fixture(:post)
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
