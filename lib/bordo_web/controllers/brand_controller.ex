defmodule BordoWeb.BrandController do
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Brands.Brand

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    brands = Brands.list_brands_for_team(team_id(conn))
    render(conn, "index.json", brands: brands)
  end

  def show(conn, %{"id" => id}) do
    brand = Brands.get_brand!(id)
    render(conn, "show.json", brand: brand)
  end

  def update(conn, %{"id" => id, "brand" => brand_params}) do
    brand = Brands.get_brand!(id)

    with {:ok, %Brand{} = brand} <- Brands.update_brand(brand, brand_params) do
      render(conn, "show.json", brand: brand)
    end
  end

  def delete(conn, %{"id" => id}) do
    brand = Brands.get_brand!(id)

    with {:ok, %Brand{}} <- Brands.delete_brand(brand) do
      send_resp(conn, :no_content, "")
    end
  end
end
