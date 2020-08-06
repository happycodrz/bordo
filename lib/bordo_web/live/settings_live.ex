defmodule BordoWeb.SettingsLive do
  use BordoWeb, :client_live_view
  import PhoenixLiveReact
  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel
  alias BordoWeb.Helpers.Svg

  @impl true
  def render(assigns) do
    ~L"""
    <div class="w-full h-full">
      <div class="p-9">
        <div class="flex items-center mb-5">
          <%= live_react_component("Components.Settings", brandId: @active_brand.id, brandImage: @active_brand.image_url) %>
          <div>
            <%= if !@editing_name do %>
              <h3><%= @active_brand.name %></h3>
              <span class="text-blue-700 cursor-pointer" phx-click="edit-brand">Edit</span>
            <% else %>
              <%= f = form_for @changeset, "#", [as: :brand, phx_submit: "save"] %>
                <div>
                  <div class="mt-1 rounded-md shadow-sm">
                    <%= text_input f, :name, class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
                    <%= error_tag f, :name %>
                  </div>
                </div>

                <div class="">
                  <span class="block w-full">
                    <span class="text-gray-700 cursor-pointer mr-2" phx-click="edit-brand">Cancel</span>
                    <button type="submit"
                      class="py-2 text-blue-700"
                      phx-disable-with="Saving...">Save</button>
                  </span>
                </div>
              </form>
            <% end %>
          </div>
        </div>
        <%= if Enum.any?(@channels) do %>
          <h3 class="border-b mb-8 mt-14 pb-2 text-gray-600">Your channels</h3>
          <div class="mb-4 grid grid-cols-5 gap-4">
            <%= for channel <- @channels do %>
              <%= channel_card(channel) %>
            <% end %>
          </div>
        <% end %>
        <%= if Enum.any?(remaining_channels(@channels)) do %>
          <h3 class="border-b border-gray-100 mb-8 mt-14 pb-2 text-gray-800">Connect a channel</h3>
          <ul class="grid grid-cols-1 gap-5 sm:gap-6 sm:grid-cols-2 lg:grid-cols-4">
            <%= for channel <- remaining_channels(@channels) do %>
              <%= add_channel_card(channel, @active_brand.id) %>
            <% end %>
          </ul>
        <% end %>
      </div>
      <div class="p-9">
        <div class="bg-white rounded-lg shadow p-8">
          <h3 class="mb-4 grid grid-cols-4 gap-4">Danger Zone</h3>
          <p>Deleting a brand is irreversable! Bordo will remove everything associated with the brand if removed.</p>
          <button phx-click="delete-brand" data-confirm="Are you sure you want to delete the brand <%= @active_brand.name %>?" class="bg-red-600 hover:bg-red-700 transition transition-all duration-150 font-weight-bold px-4 py-2 text-white">Delete</button>
        </div>
      </div>
      <div class="pin-b">
        <p class="text-xs text-center text-gray-500 mb-2">
          <%= System.get_env("RENDER_GIT_COMMIT", "dev") %>&nbsp;&nbsp;|&nbsp;&nbsp;&copy;<%= DateTime.utc_now.year %> Bordo, LLC&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://hellobordo.com/privacy-policy" class="text-gray-500 underline">Privacy Policy</a>
        </p>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)
    channels = Channels.list_channels(brand_id: active_brand.id)

    {:ok,
     assign(socket,
       active_brand: active_brand,
       channels: channels,
       editing_name: false,
       nav_item: "settings",
       changeset: Brand.changeset(active_brand, %{})
     )}
  end

  @impl true
  def handle_event("delete-channel", %{"channel_id" => channel_id}, socket) do
    channel = Channels.get_channel!(channel_id)
    Channels.delete_channel(channel)
    channels = Channels.list_channels(brand_id: socket.assigns.active_brand.id)
    {:noreply, socket |> put_flash(:success, "Channel removed") |> assign(channels: channels)}
  end

  @doc """
  Handle the delete-brand click. We'll use @active_brand instead of a value
  """
  def handle_event("delete-brand", _params, socket) do
    Brands.delete_brand(socket.assigns.active_brand)

    {
      :noreply,
      socket |> redirect(to: Routes.live_path(socket, BordoWeb.OnboardingLive.Index))
    }
  end

  def handle_event("edit-brand", _params, socket) do
    {:noreply, assign(socket, editing_name: !socket.assigns.editing_name)}
  end

  def handle_event("save", params, socket) do
    brand = socket.assigns.active_brand

    case Brands.update_brand(brand, params["brand"]) do
      {:ok, %Brand{} = brand} ->
        {:noreply, assign(socket, active_brand: brand, editing_name: false)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def channel_card(channel) do
    ~e"""
    <div class="flex flex-col transition transition-all duration-150 hover:shadow-lg bg-white overflow-hidden sm:rounded-lg sm:shadow">
      <div class="flex-1 py-8">
        <div>
          <div class="mb-4 flex items-center w-full justify-center">
            <div class="w-10 h-10 mr-2">
              <%= card_logo(channel.network) %>
            </div>
            <%= feather_icon("link", "mr-2 text-gray-500") %>
            <div class="flex-shrink-0">
              <img class="h-12 w-12 rounded-full" src="<%= connection_url(channel) %>" alt="" />
            </div>
          </div>
          <div class="text-center">
            <%= card_resource_info(channel) %>
            <%= if channel.network == "facebook" do %>
              <%= link(
                "Reauthorize Facebook",
                to: Routes.facebook_path(BordoWeb.Endpoint, :reauth, %{"brand_id" => channel.brand_id}),
                data: [integration: "facebook"]
              ) %>
            <% end %>
          </div>
        </div>
      </div>
      <button phx-click="delete-channel" phx-value-channel_id="<%= channel.id %>" class="bg-red-600 hover:bg-red-700 transition transition-all duration-150 font-weight-bold px-4 py-2 text-white w-100">
        Remove Connection
      </button>
    </div>
    """
  end

  defp add_channel_card(channel, brand_id) do
    link =
      case channel do
        "twitter" ->
          Routes.twitter_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

        "facebook" ->
          Routes.facebook_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

        "linkedin" ->
          Routes.linkedin_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

          # "google" ->
          #   Routes.google_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})
      end

    ~e"""
    <li class="col-span-1 flex shadow-sm rounded-md">
      <div class="flex-1 flex items-center justify-between border border-gray-100 bg-white rounded-md truncate">
        <div class="flex-1 flex items-center content-center px-4 py-3 text-sm leading-5 truncate">
          <div class="mr-3">
            <%= card_logo(channel) %>
          </div>
          <h3 class="text-gray-900 font-medium text-base"><%= String.capitalize(channel) %></h3>
        </div>
        <div class="flex-shrink-0 pr-3">
          <span class="inline-flex rounded-md shadow-sm">
          <%= link(
            to: link,
            class:
              "inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
          ) do %>
            <%= feather_icon("plus") %>
          <% end %>
        </span>
      </div>
    </li>
    """
  end

  defp remaining_channels(channels) do
    networks = Channel.supported_networks()
    channel_networks = Enum.map(channels, &Map.get(&1, :network))
    Enum.reject(networks, fn network -> Enum.member?(channel_networks, network) end)
  end

  defp card_logo(channel) do
    case channel do
      "facebook" ->
        Svg.social_icon("fb", style: "fill: #1877f2; width: 2.5rem; height: 2.5rem;")

      "twitter" ->
        Svg.social_icon("twitter",
          class: "stroke-current",
          style: "fill: #1da1f2; width: 2.5rem; height: 2.5rem;"
        )

      "linkedin" ->
        Svg.social_icon("linkedin", style: "fill: #2867b2; width: 2.5rem; height: 2.5rem;")

      "google" ->
        "na"
    end
  end

  defp connection_url(%Channel{network: "twitter"} = channel) do
    channel.resource_info["profile_image_url_https"] |> String.replace("_normal", "")
  end

  defp connection_url(%Channel{network: "facebook"} = channel) do
    channel.resource_info["picture"]["data"]["url"]
  end

  defp connection_url(%Channel{network: "linkedin"} = channel) do
    channel.image_url
  end

  defp connection_url(%Channel{network: "google"} = channel) do
    ""
  end

  defp card_resource_info(%Channel{network: "twitter"} = channel) do
    ~e"""
    <div class="text-gray-800">
      <%= channel.resource_info["name"] %>
    </div>
    <a href="https://twitter.com/<%= channel.resource_info["screen_name"] %>" target="_blank" class="text-xs">
      @<%= channel.resource_info["screen_name"] %>
    </a>
    """
  end

  defp card_resource_info(%Channel{network: "facebook"} = channel) do
    ~e"""
    <div class="text-gray-800">
      <%= channel.resource_info["name"] %>
    </div>
    """
  end

  defp card_resource_info(%Channel{network: "linkedin"} = channel) do
    ~e"""
    <div class="text-gray-800">
      <%= channel.resource_info["localizedName"] %>
    </div>
    """
  end

  defp card_resource_info(%Channel{network: "google"} = channel) do
    ~e"""
    """
  end
end
