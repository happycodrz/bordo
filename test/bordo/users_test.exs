defmodule Bordo.UsersTest do
  use Bordo.DataCase

  alias Bordo.Users

  describe "users" do
    alias Bordo.Users.User

    @valid_attrs %{email: "some@email.com", password: "8charpass"}
    @update_attrs %{email: "updated@email.com", password: "8charpass2"}
    @invalid_attrs %{email: nil}

    test "list_users/0 returns all users" do
      user = fixture(:user)
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = fixture(:user)
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some@email.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = fixture(:user)
      assert {:ok, %User{} = user} = Users.update_user(user, @update_attrs)
      assert user.email == "updated@email.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = fixture(:user)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = fixture(:user)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = fixture(:user)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
