defmodule BordoWeb.BrandNav do
  use BordoWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="bg-blue-800 text-blue-900 w-18 p-3 flex flex-col h-full">
      <div class="flex-1 ">
        <%= for brand <- @brands do %>
        <div class="cursor-pointer mb-3">
          <%= link to: Routes.live_path(@socket, BordoWeb.ReactLive, brand.slug), class: "hover:no-underline" do %>
            <%= brand_nav_avatar(brand, @brand_slug) %>
            <% end %>
          </div>
        <% end %>
        <%= live_component(@socket, BordoWeb.BrandModal, show_modal: @show_modal, current_identity: @current_identity, id: :new_brand_modal) %>
      </div>
      <div class="pin-b" x-data="{ open: false }"  phx-update="ignore">
        <div class="relative z-10">
          <img @click="open = !open" @click.away="open = false" class="h-12 rounded-full cursor-pointer" src="<%= BordoWeb.Admin.UserView.avatar(@current_user) %>" alt="" />
          <div x-show="open" class="origin-top absolute left-0 mt-2 w-48 rounded-md shadow-lg" x-description="Profile dropdown panel, show/hide based on dropdown state." x-transition:enter="transition ease-out duration-200" x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100" x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100" x-transition:leave-end="transform opacity-0 scale-95">
            <div class="py-1 rounded-md bg-white shadow-xs">
              <%= link "Sign out", to: Routes.logout_path(@socket, :index), class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100" %>
            </div>
          </div>
        </div>

      </div>
    </div>
    """
  end

  def brand_nav_avatar(brand, brand_slug) do
    active = brand.slug == brand_slug

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
end
