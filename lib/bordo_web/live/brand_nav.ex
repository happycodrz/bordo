defmodule BordoWeb.BrandNav do
  use BordoWeb, :client_live_view

  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Users
  alias BordoWeb.Helpers.BrandHelper
  alias BordoWeb.Live.AuthHelper

  def render(assigns) do
    ~L"""
    <div class="h-full flex">
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
            <%= feather_icon("settings") %>
          <% end %>
        </div>
        <div class="pin-bx" x-data="{ open: false }"  phx-update="ignore">
          <%= link to: Routes.logout_path(@socket, :index), class: "block p-2 text-center text-blue-300 hover:text-blue-100" do %>
            <%= feather_icon("log-out") %>
          <% end %>
        </div>
      </div>

      <div class="flex flex-col max-w-sm" style="width: 25vw">
        <div class="flex flex-col h-0 flex-1 border-r border-gray-200 bg-white">
          <div class="flex-1 flex flex-col overflow-y-auto">
            <div class="border-b border-gray-200 relative">
              <div class="flex items-center justify-between flex-shrink-0 px-4 h-20 w-full focus:outline-none focus:border-0">
                <div>
                  <span class="text-xl truncate text-gray-900"><%= @active_brand.name %></span>
                </div>
              </div>
            </div>
            <nav class="flex-1 bg-white space-y-1 py-4">
              <%= nav_link(Routes.live_path(@socket, BordoWeb.LaunchpadLive, @active_brand.slug), @nav_item, "Launchpad", "zap") %>
              <%= if brand_configured?(@active_brand) do %>
                <%= nav_link(Routes.live_path(@socket, BordoWeb.CalendarLive, @active_brand.slug), @nav_item, "Schedule", "calendar") %>
                <%= nav_link(Routes.live_path(@socket, BordoWeb.MediaLive, @active_brand.slug), @nav_item, "Media", "image") %>
                <%= nav_link(Routes.live_path(@socket, BordoWeb.SettingsLive, @active_brand.slug), @nav_item, "Settings", "settings") %>
              <% end %>
            </nav>
          </div>
          <div class="flex-shrink-0 flex p-6">
            <span class="flex rounded-md shadow-sm w-full">
              <button id="post-slideover-button" class="w-full inline-flex justify-center items-center px-4 py-3 border border-transparent leading-6 font-medium rounded-md text-white bg-red-600 hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red active:bg-red-700 transition ease-in-out duration-150 text-lg" phx-target="#new-post" phx-click="open-slideover">
                <%= feather_icon("send", "-ml-1 mr-3 w-5 h-5") %>
                New Post
              </button>
            </span>
          </div>
        </div>
      </div>
    </div>

    <%= live_component(@socket, BordoWeb.Posts.NewLive, id: "post-slideover", active_brand: @active_brand, channels: [], changeset: nil, show_slideover: false, post: nil, current_user_id: @current_user.id, live_action: :new) %>
    """
  end

  def mount(_, %{"brand_slug" => brand_slug, "nav_item" => nav_item} = session, socket) do
    {:ok, current_identity} = AuthHelper.load_user(session)
    current_user = Users.get_user!(current_identity.user_id)

    brands = fetch_brands(current_user.team_id)
    active_brand = Brands.get_brand!(slug: brand_slug, preloads: [:channels])

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
      ~e"""
      <div
        class="<%= avatar_class(active) %>">
        <%= BrandHelper.brand_letters(brand) %>
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

  defp nav_link_class(active) do
    link_class =
      "group flex items-center py-2 px-4 text-sm leading-5 font-medium border-r-4 transition ease-in-out duration-150 hover:no-underline"

    if active do
      link_class <>
        " text-blue-600 bg-blue-100 border-blue-600 focus:outline-none focus:bg-blue-100"
    else
      link_class <>
        " border-transparent hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:text-gray-900 focus:bg-gray-100"
    end
  end

  defp nav_icon_class(active) do
    icon_class = "w-6 transition ease-in-out duration-150"

    if active do
      icon_class <> " text-blue-900"
    else
      icon_class <> " text-gray-400 group-hover:text-gray-600 group-focus:text-gray-600"
    end
  end

  defp nav_link(route, nav_item, title, icon) do
    active = nav_item == String.downcase(title)

    ~e"""
      <%= live_patch to: route, class: nav_link_class(active) do %>
        <div class="w-10 h-10 mr-3 inline-flex items-center justify-center">
          <%= feather_icon(icon, nav_icon_class(active)) %>
        </div>
        <%= title %>
      <% end %>
    """
  end

  defp brand_configured?(%Brand{channels: channels}) do
    Enum.any?(channels)
  end
end
