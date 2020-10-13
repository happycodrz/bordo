defmodule BordoWeb.NavView do
  @moduledoc false
  use BordoWeb, :view

  alias BordoWeb.Helpers.BrandHelper

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

  defp nav_link(route, live_action, title, icon) do
    active = Atom.to_string(live_action) == String.downcase(title)

    ~e"""
      <%= live_patch to: route, class: nav_link_class(active) do %>
        <div class="w-10 h-10 mr-3 inline-flex items-center justify-center">
          <%= feather_icon(icon, nav_icon_class(active)) %>
        </div>
        <%= title %>
      <% end %>
    """
  end
end
