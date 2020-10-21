defmodule BordoWeb.Providers.ZapierController do
  @moduledoc """
  Handles zapier channel creation internal to Bordo
  """
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Channels

  def auth(conn, %{"brand_id" => brand_id}) do
    brand = Brands.get_brand!(brand_id)

    Channels.create_channel(%{
      "brand_id" => brand_id,
      "token" => generate_token(),
      "network" => "zapier"
    })

    conn
    |> put_flash(:success, "Zapier Connected!")
    |> redirect(to: Routes.bordo_path(conn, :settings, brand.slug))
  end

  def check(conn, _params) do
    [api_key] = get_req_header(conn, "x-api-key")
    channel = Channels.get_channel!(token: api_key) |> Bordo.Repo.preload(brand: :team)

    conn
    |> put_status(:ok)
    |> json(%{
      status: "success",
      brand: channel.brand.name,
      team: channel.brand.team.name,
      label: channel.label
    })
  end

  defp generate_token, do: :crypto.strong_rand_bytes(24) |> Base.url_encode64()
end
