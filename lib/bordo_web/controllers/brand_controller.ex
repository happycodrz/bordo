defmodule BordoWeb.BrandController do
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Brands.{Brand}
  alias Ecto.Multi

  action_fallback BordoWeb.FallbackController

  def index(conn, _params) do
    brands = Brands.list_brands_for_team(conn |> team_id())
    render(conn, "index.json", brands: brands)
  end

  def create(conn, %{"brand" => brand_params}) do
    case create_brand(
           brand_params,
           user_id(conn),
           team_id(conn)
         ) do
      {:ok, %{brand: brand}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.brand_path(conn, :show, brand))
        |> render("show.json", brand: brand)

      {:error, :brand, err, _} ->
        {:error, err}
    end
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

  defp create_brand(attrs, user_id, team_id) do
    Multi.new()
    |> Multi.insert(
      :brand,
      Brand.changeset(%Brand{}, attrs)
    )
    |> Multi.run(:brand_team, fn _repo, %{brand: brand} ->
      Brands.create_brand_team(%{"brand_id" => brand.id, "team_id" => team_id})
    end)
    |> Bordo.Repo.transaction()
  end
end
