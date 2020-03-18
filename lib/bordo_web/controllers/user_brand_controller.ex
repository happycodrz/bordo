defmodule BordoWeb.UserBrandController do
  use BordoWeb, :controller

  alias Bordo.Brands.UserBrand
  alias Bordo.Users

  action_fallback BordoWeb.FallbackController

  def create(conn, %{"user_brand" => user_brand_params}) do
    with {:ok, %UserBrand{} = user_brand} <- Users.create_user_brand(user_brand_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user_brand))
      |> render("show.json", user_brand: user_brand)
    end
  end
end
