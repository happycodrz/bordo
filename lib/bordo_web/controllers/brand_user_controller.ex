defmodule BordoWeb.BrandUserController do
  use BordoWeb, :controller

  alias Bordo.Brands.BrandUser
  alias Bordo.Users

  action_fallback BordoWeb.FallbackController

  def create(conn, %{"brand_user" => user_brand_params}) do
    with {:ok, %BrandUser{} = user_brand} <- Users.create_brand_user(user_brand_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.brand_user_path(conn, :show, user_brand.brand_id, user_brand.user_id)
      )
      |> render("show.json", user_brand: user_brand)
    end
  end
end
