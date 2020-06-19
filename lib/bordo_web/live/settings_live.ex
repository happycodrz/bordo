defmodule BordoWeb.SettingsLive do
  use BordoWeb, :client_live_view
  import PhoenixLiveReact
  alias Bordo.Brands

  @impl true
  def render(assigns) do
    ~L"""
    <div class="m-8">
      <%= live_react_component("Components.Settings", brandId: @active_brand.id, brandName: @active_brand.name, brandSlug: @active_brand.slug, brandImage: @active_brand.image_url) %>
    </div>
    """
  end

  @impl true
  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)

    {:ok, assign(socket, active_brand: active_brand, nav_item: "settings")}
  end
end
