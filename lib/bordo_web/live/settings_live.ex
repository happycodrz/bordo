defmodule BordoWeb.SettingsLive do
  use BordoWeb, :client_live_view
  import PhoenixLiveReact
  alias Bordo.Brands
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  @impl true
  def render(assigns) do
    ~L"""
    <div class="w-full h-full">
      <div class="p-9">
        <%= live_react_component("Components.Settings", brandId: @active_brand.id, brandName: @active_brand.name, brandSlug: @active_brand.slug, brandImage: @active_brand.image_url) %>
        <%= if Enum.any?(@channels) do %>
          <h3 class="border-b mb-8 mt-14 pb-2 text-gray-600">Your channels</h3>
          <div class="mb-4 grid grid-cols-5 gap-4">
            <%= for channel <- @channels do %>
              <%= channel_card(channel) %>
            <% end %>
          </div>
        <% end %>
        <%= if Enum.any?(remaining_channels(@channels)) do %>
          <h3 class="border-b mb-8 mt-14 pb-2 text-gray-600">Connect a channel</h3>
          <div class="mb-4 grid grid-cols-5 gap-6">
            <%= for channel <- remaining_channels(@channels) do %>
              <%= add_channel_card(channel, @active_brand.id) %>
            <% end %>
          </div>
        <% end %>
      </div>
      <div class="p-9">
        <div class="bg-white rounded-lg shadow p-8">
          <h3 class="mb-4 grid grid-cols-5 gap-4">Danger Zone</h3>
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

    {:ok, assign(socket, active_brand: active_brand, channels: channels, nav_item: "settings")}
  end

  @impl true
  def handle_event("delete-channel", %{"channel_id" => channel_id}, socket) do
    channel = Channels.get_channel!(channel_id)
    Channels.delete_channel(channel)
    channels = Channels.list_channels(brand_id: socket.assigns.active_brand.id)
    {:noreply, assign(socket, channels: channels)}
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
      end

    ~e"""
      <%= link(
        to: link,
        class:
          "group hover:shadow-lg transition transition-all duration-150 bg-white flex flex-col overflow-hidden rounded shadow-md",
        data: [integration: "facebook"]
      ) do %>
        <div class="flex flex-1 items-center justify-center w-full py-15">
          <div class="w-20 h-20">
            <%= card_logo(channel) %>
          </div>
        </div>
        <div class="bg-blue-600 block group-hover:bg-blue-500 transition transition-all duration-150 hover:no-underline items-center px-4 py-2 shadow-md text-center text-white w-100">
          Connect →
        </div>
      <% end %>
    """
  end

  defp remaining_channels(channels) do
    networks = ["twitter", "facebook", "linkedin"]
    channel_networks = Enum.map(channels, &Map.get(&1, :network))
    Enum.reject(networks, fn network -> Enum.member?(channel_networks, network) end)
  end

  defp card_logo(channel) do
    case channel do
      "facebook" -> fb_logo()
      "twitter" -> twitter_logo()
      "linkedin" -> linkedin_logo()
    end
  end

  defp fb_logo do
    ~e"""
    <img src="<%= Routes.static_path(BordoWeb.Endpoint, "/images/fb.svg") %>" />
    """
  end

  defp twitter_logo do
    ~e"""
    <img src="<%= Routes.static_path(BordoWeb.Endpoint, "/images/twitter.svg") %>" />
    """
  end

  defp linkedin_logo do
    ~e"""
    <img src="<%= Routes.static_path(BordoWeb.Endpoint, "/images/linkedin.svg") %>" />
    """
  end

  defp connection_url(%Channel{network: "twitter"} = channel) do
    channel.resource_info["profile_image_url_https"] |> String.replace("_normal", "")
  end

  defp connection_url(%Channel{network: "facebook"} = channel) do
    channel.resource_info["picture"]["data"]["url"]
  end

  defp connection_url(%Channel{network: "linkedin"} = channel) do
    org_info = Linkedin.get_profile_image(channel.token, channel.resource_id)

    %{
      "logoV2" => %{
        "original~" => %{"elements" => [%{"identifiers" => [%{"identifier" => url} | _]} | _]}
      }
    } = org_info

    url
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
end
