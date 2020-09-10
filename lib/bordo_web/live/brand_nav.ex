defmodule BordoWeb.BrandNav do
  use BordoWeb, :client_live_view

  alias Bordo.Brands
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  def render(assigns) do
    ~L"""
    <nav class="h-full flex">
      <div class="bg-blue-800 text-blue-50 w-18 p-3 flex flex-col h-full" id="brand-nav">
        <div class="flex-1 ">
          <%= for brand <- @brands do %>
          <div class="cursor-pointer mb-3">
            <%= live_redirect to: Routes.live_path(@socket, BordoWeb.LaunchpadLive, brand.slug), class: "hover:no-underline" do %>
              <%= brand_nav_avatar(brand, @active_brand.slug) %>
              <% end %>
            </div>
          <% end %>
          <%= live_component(@socket, BordoWeb.BrandModal, id: "brand-modal", team_id: @current_user.team_id) %>
        </div>
        <div class="pin-bx" x-data="{ open: false }"  phx-update="ignore">
          <%= live_redirect to: Routes.live_path(@socket, BordoWeb.TeamSettingsLive, @active_brand.slug), class: "block p-2 text-center text-blue-300 hover:text-blue-100" do %>
            <i data-feather="settings"></i>
          <% end %>
        </div>
        <div class="pin-bx" x-data="{ open: false }"  phx-update="ignore">
          <%= link to: Routes.logout_path(@socket, :index), class: "block p-2 text-center text-blue-300 hover:text-blue-100" do %>
            <i data-feather="log-out"></i>
          <% end %>
        </div>
      </div>
      <aside class="bdo-brandSidebar flex flex-col shadow-md border-r border-gray-100 relative">
        <header class="bg-white px-3 py-10 flex justify-content-between align-items-center border-b border-gray-100">
            <h2 class="text-3xl m-0"><%= @active_brand.name %></h2>
        </header>
        <nav class="nav flex-column nav-secondary h-full bg-gray-50">
          <%= nav_link(Routes.live_path(@socket, BordoWeb.LaunchpadLive, @active_brand.slug), @nav_item, "Launchpad", "zap") %>
          <%= nav_link(Routes.live_path(@socket, BordoWeb.CalendarLive, @active_brand.slug), @nav_item, "Schedule", "calendar") %>
          <%= nav_link(Routes.live_path(@socket, BordoWeb.MediaLive, @active_brand.slug), @nav_item, "Media", "image") %>
          <%= nav_link(Routes.live_path(@socket, BordoWeb.SettingsLive, @active_brand.slug), @nav_item, "Settings", "settings") %>
        </nav>
        <div class="pin-b px-4 mb-2 bg-gray-50">
          <button id="post-slideover-button" class="btn btn-danger btn-lg btn-block d-flex align-items-center justify-content-center mb-2" phx-target="#new-post" phx-click="open-slideover">
            <%= feather_icon("send", "mr-2") %>
            New Post
          </button>
        </div>
      </aside>
      <%= live_component(@socket, BordoWeb.Posts.NewLive, id: "post-slideover", active_brand: @active_brand, channels: [], changeset: nil, show_slideover: false, post: nil, current_user: @current_user) %>
    </nav>
    """
  end

  def mount(_, %{"brand_slug" => brand_slug, "nav_item" => nav_item} = session, socket) do
    {:ok, current_identity} = AuthHelper.load_user(session)
    current_user = Users.get_user!(current_identity.user_id)

    brands = fetch_brands(current_user.team_id)
    active_brand = Brands.get_brand!(slug: brand_slug)

    {:ok,
     assign(socket,
       brands: brands,
       current_user: current_user,
       active_brand: active_brand,
       nav_item: nav_item
     )}
  end

  defp fetch_brands(team_id) do
    Brands.list_brands_for_team(team_id)
  end

  def brand_nav_avatar(brand, current_brand_slug) do
    active = brand.slug == current_brand_slug

    if brand.image_url == nil do
      letters =
        brand.name
        |> String.split(" ")
        |> Enum.map(fn x -> x |> String.graphemes() |> Enum.at(0) end)
        |> Enum.join()

      ~e"""
      <div
        class="<%= avatar_class(active) %>">
        <%= letters %>
      </div>
      """
    else
      ~e"""
      <div
        class="<%= avatar_class(active) %>">
        <img src=<%= brand.image_url %> alt=<%= brand.name %>>
      </div>
      """
    end
  end

  defp avatar_class(active) do
    if active do
      "bg-white h-12 hover:no-underline w-12 flex items-center justify-center text-gray-500 text-2xl font-semibold rounded-lg mb-1 overflow-hidden"
    else
      "bg-white h-12 hover:no-underline w-12 flex items-center justify-center text-gray-500 text-2xl font-semibold rounded-lg mb-1 overflow-hidden opacity-50 hover:opacity-100 transition duration-150"
    end
  end

  defp nav_link(route, nav_item, title, icon) do
    active = nav_item == String.downcase(title)

    class =
      if active do
        "bdo-brandNav__link nav-link p-3 d-flex align-items-center active"
      else
        "bdo-brandNav__link nav-link p-3 d-flex align-items-center"
      end

    ~e"""
    <div class="nav-item">
      <%= live_patch to: route, class: class do %>
        <%= feather_icon(icon, "mr-3") %>
        <%= title %>
      <% end %>
    </div>
    """
  end
end
