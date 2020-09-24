defmodule BordoWeb.LaunchpadLive do
  use BordoWeb, :client_live_view

  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  @impl true
  def render(assigns) do
    ~L"""
    <div class="h-screen">
      <section
        class="h-screen d-flex align-items-center justify-content-center bg-geometry"
      >
      <%= if brand_configured?(@active_brand) do %>
        <header class="text-center">
          <p class="text-5xl">
            <%= @greeting %>, <span class="text-primary"><%= @user_greeting %></span>!
            <span class="wave" role="img">
              👋
            </span>
          </p>
          <h1 class="mb-5">What do you want to accomplish today?</h1>
          <div class="pt-5 card-deck">
            <div class="text-dark card cursor-pointer transition duration-300 ease-in-out transform hover:- hover:scale-110 hover:shadow-xl" style="text-decoration: none;" onclick="document.getElementById('post-slideover-button').click()">
              <div class="card-body">
                <div class="mb-5 bg-primary rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                  style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("send", "w-48") %></div>
                <div class="mb-5 h5 card-title h5">Schedule a new post</div>
              </div>
              <div class="bg-primary text-light card-footer">Let's go!</div>
            </div>

            <%= link to: Routes.live_path(@socket, BordoWeb.CalendarLive, @active_brand.slug), class: "text-dark card hover:no-underline transition duration-300 ease-in-out transform hover:- hover:scale-110 hover:shadow-xl" do %>
              <div class="card-body">
                <div class="mb-5 bg-danger rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                  style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("calendar", "w-48") %></div>
                <div class="mb-5 h5 card-title h5 text-gray-700">See my upcoming posts</div>
              </div>
              <div class="bg-danger text-light card-footer">Let's go!</div>
            <% end %>

            <%= link to: Routes.live_path(@socket, BordoWeb.MediaLive, @active_brand.slug), class: "text-dark card hover:no-underline transition duration-300 ease-in-out transform hover:- hover:scale-110 hover:shadow-xl" do %>
              <div class="card-body">
                <div class="mb-5 bg-success rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                  style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("image", "w-48") %></div>
                <div class="mb-5 h5 card-title h5">Upload a new image or graphic</div>
              </div>
              <div class="bg-success text-light card-footer">Let's go!</div>
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
      </section>
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
