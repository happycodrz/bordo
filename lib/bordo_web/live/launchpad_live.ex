defmodule BordoWeb.LaunchpadLive do
  use BordoWeb, :client_live_view

  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  @impl true
  def render(assigns) do
    ~L"""
    <div class="h-full flex flex-col items-center justify-center bg-geometry">
      <%= if brand_configured?(@active_brand) do %>
          <p class="text-6xl text-gray-700">
            <%= @greeting %>, <span class="text-blue-600"><%= @user_greeting %></span>!
            <span class="wave" role="img">
              👋
            </span>
          </p>
          <h1 class="mb-20 text-lg text-gray-700">What do you want to accomplish today?</h1>
          <div class="w-3/5 max-w-4/5 grid grid-cols-3 col-gap-8">
            <div class="flex flex-col items-center bg-white pt-16 rounded-lg shadow cursor-pointer transition duration-300 ease-in-out transform hover:scale-110 hover:shadow-xl" style="text-decoration: none;" onclick="document.getElementById('post-slideover-button').click()">
              <div class="absolute flex items-center justify-center rounded-full w-16 h-16 top-0 -mt-8 bg-red-500"><%= feather_icon("send", "w-8 h-8 text-white") %></div>
              <div class="text-xl text-center flex-1 pb-12 px-8 text-gray-700">Schedule a new post</div>
              <div class="bg-red-500 px-8 py-4 text-white font-medium w-full text-center rounded-b-lg">Let's go!</div>
            </div>

            <%= link to: Routes.live_path(@socket, BordoWeb.CalendarLive, @active_brand.slug), class: "flex flex-col items-center bg-white pt-16 rounded-lg shadow cursor-pointer hover:no-underline transition duration-300 ease-in-out transform hover:scale-110 hover:shadow-xl" do %>
              <div class="absolute flex items-center justify-center rounded-full w-16 h-16 top-0 -mt-8 bg-blue-600"><%= feather_icon("calendar", "w-8 h-8 text-white") %></div>
              <div class="text-xl text-center flex-1 pb-12 px-8 text-gray-700">See my upcoming posts</div>
              <div class="bg-blue-600 px-8 py-4 text-white font-medium w-full text-center rounded-b-lg">Let's go!</div>
            <% end %>

            <%= link to: Routes.live_path(@socket, BordoWeb.MediaLive, @active_brand.slug), class: "flex flex-col items-center bg-white pt-16 rounded-lg shadow cursor-pointer hover:no-underline transition duration-300 ease-in-out transform hover:scale-110 hover:shadow-xl" do %>
              <div class="absolute flex items-center justify-center rounded-full w-16 h-16 top-0 -mt-8 bg-green-400"><%= feather_icon("image", "w-8 h-8 text-white") %></div>
              <div class="text-xl text-center flex-1 pb-12 px-8 text-gray-700">Upload a new image or graphic</div>
              <div class="bg-green-400 px-8 py-4 text-white font-medium w-full text-center rounded-b-lg">Let's go!</div>
            <% end %>
          </div>
        <% else %>
          <div class="bg-white shadow sm:rounded-lg">
            <div class="px-4 py-5 sm:p-6">
              <h3 class="text-lg leading-6 font-medium text-gray-900">
                You're almost done!
              </h3>
              <div class="mt-2 max-w-xl text-sm leading-5 text-gray-500">
                <p>
                  Before you can schedule posts, you need to connect one or more social channels in this brand's settings.
                </p>
              </div>
              <div class="mt-3 text-sm leading-5">
                <%= link to: Routes.live_path(@socket, BordoWeb.SettingsLive, @active_brand.slug), class: "font-medium text-indigo-600 hover:text-indigo-500 transition ease-in-out duration-150" do %>
                Setup social channels in settings &rarr;
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
    </div>
    """
  end

  @impl true
  def mount(%{"brand_slug" => brand_slug}, session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug, preloads: [:channels])

    {:ok, current_identity} = AuthHelper.load_user(session)
    current_user = Users.get_user!(current_identity.user_id)
    user_greeting = current_user.first_name || current_user.email

    greeting =
      Enum.random([
        "Hello",
        "Welcome back",
        "Howdy",
        "What's up",
        "Hola",
        "Sup",
        "Hey",
        "Hey there"
      ])

    {:ok,
     assign(socket,
       active_brand: active_brand,
       user_greeting: user_greeting,
       nav_item: "launchpad",
       greeting: greeting
     )}
  end

  defp brand_configured?(%Brand{channels: channels}) do
    Enum.any?(channels)
  end
end
