defmodule BordoWeb.LaunchpadLive do
  use BordoWeb, :client_live_view
  import PhoenixLiveReact
  alias Bordo.Brands
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  @impl true
  def render(assigns) do
    ~L"""
    <div class="h-screen">
      <section
        class="h-screen d-flex align-items-center justify-content-center bg-geometry"
      >
      <header class="text-center">
        <p class="h2">
          <%= @greeting %>, <span class="text-primary"><%= @user_greeting %></span>!
          <span class="wave" role="img">
            👋
          </span>
        </p>
        <h1 class="mb-5">What do you want to accomplish today?</h1>
        <div class="pt-5 card-deck">
          <div class="text-dark bdo-launchpadCard card" style="text-decoration: none;" onclick="document.getElementById('newPostButton').click()">
            <div class="card-body">
              <div class="mb-5 bg-primary rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("send", "w-48") %></div>
              <div class="mb-5 h5 card-title h5">Schedule a new post</div>
            </div>
            <div class="bg-primary text-light card-footer">Let's go!</div>
          </div>

          <%= link to: Routes.live_path(@socket, BordoWeb.ScheduleLive, @active_brand.slug), class: "text-dark bdo-launchpadCard card hover:no-underline" do %>
            <div class="card-body">
              <div class="mb-5 bg-danger rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("calendar", "w-48") %></div>
              <div class="mb-5 h5 card-title h5 text-gray-700">See my upcoming posts</div>
            </div>
            <div class="bg-danger text-light card-footer">Let's go!</div>
          <% end %>

          <%= link to: Routes.live_path(@socket, BordoWeb.MediaLive, @active_brand.slug), class: "text-dark bdo-launchpadCard card hover:no-underline" do %>
            <div class="card-body">
              <div class="mb-5 bg-success rounded-circle d-flex align-items-center justify-content-center mx-auto text-white"
                style="width: 75px; height: 75px; margin-top: -24%;"><%= feather_icon("image", "w-48") %></div>
              <div class="mb-5 h5 card-title h5">Upload a new image or graphic</div>
            </div>
            <div class="bg-success text-light card-footer">Let's go!</div>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def mount(%{"brand_slug" => brand_slug}, session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)

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
end