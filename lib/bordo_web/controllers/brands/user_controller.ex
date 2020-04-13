defmodule BordoWeb.Brands.UserController do
  use BordoWeb, :controller

  alias Bordo.Users

  action_fallback BordoWeb.FallbackController

  def index(conn, %{"brand_id" => slug}) do
    users = Users.list_users_for_brand(slug)
    render(conn, "index.json", users: users)
  end

  # def show(conn, %{"id" => id}) do
  #   user = Users.get_user!(id)
  #   render(conn, "show.json", user: user)
  # end

  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Users.get_user!(id)

  #   with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   user = Users.get_user!(id)

  #   with {:ok, %User{}} <- Users.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
