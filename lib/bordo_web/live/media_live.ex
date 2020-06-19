defmodule BordoWeb.MediaLive do
  use BordoWeb, :client_live_view
  import PhoenixLiveReact
  alias Bordo.Brands

  @impl true
  def render(assigns) do
    ~L"""
    <div class="m-8">
      <%= live_react_component("Components.Media", brandId: @active_brand.id) %>
    </div>
    """
  end

  @impl true
  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)

    {:ok, assign(socket, active_brand: active_brand, nav_item: "media")}
  end
end
