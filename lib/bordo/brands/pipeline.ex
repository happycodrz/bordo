defmodule Bordo.Brands.Pipeline do
  use Plug.Builder

  plug :brand_resource

  def brand_resource(%Plug.Conn{params: %{"brand_id" => brand_id}} = conn, _opts) do
    assign(conn, :brand_id, brand_id)
  end
end
