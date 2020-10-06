defmodule BordoWeb.SettingsLive do
  use BordoWeb, :live_component
  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel
  alias BordoWeb.Helpers.BrandHelper
  alias BordoWeb.Helpers.Svg

  @impl true
  def render(assigns) do
    ~L"""
    <div class="min-w-full min-h-full bg-gray-50" id="settings-live">
      <div class="p-9">
        <div class="flex items-center mb-5">
          <div className="flex align-items-center">
            <%= if is_nil(@active_brand.image_url) do %>
              <div phx-hook="UploadMedia" phx-target="#settings-live" class="inline-block h-20 w-20 rounded-md mr-4 cursor-pointer bg-white h-12 hover:no-underline w-12 flex items-center justify-center text-gray-500 text-2xl font-semibold rounded-lg mb-1 overflow-hidden">
                <%= BrandHelper.brand_letters(@active_brand) %>
              </div>
            <% else %>
              <img phx-hook="UploadMedia" phx-target="#settings-live" class="inline-block h-20 w-20 rounded-md mr-4 cursor-pointer" src="<%= @active_brand.image_url %>" alt="">
            <% end %>
          </div>
          <div>
            <%= if !@editing_name do %>
              <h3 class="text-2xl"><%= @active_brand.name %></h3>
              <span class="text-blue-700 cursor-pointer" phx-click="edit-brand" phx-target="#settings-live">Edit</span>
            <% else %>
              <%= f = form_for @changeset, "#", [as: :brand, phx_submit: "save", phx_target: "#settings-live"] %>
                <div>
                  <div class="mt-1 rounded-md shadow">
                    <%= text_input f, :name, class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
                    <%= error_tag f, :name %>
                  </div>
                </div>

                <div class="">
                  <span class="block w-full">
                    <span class="text-gray-700 cursor-pointer mr-2" phx-click="edit-brand" phx-target="#settings-live">Cancel</span>
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
          <div class="mb-14">
            <h3 class="border-b mb-8 mt-14 pb-2 text-gray-600 text-xl">Your channels</h3>
            <ul class="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
              <%= for channel <- @channels do %>
                <%= channel_card(channel) %>
              <% end %>
            </ul>
          </div>
        <% end %>
        <%= if Enum.any?(remaining_channels(@channels)) do %>
          <div class="mb-14">
            <h3 class="border-b mb-8 pb-2 text-gray-600 text-xl">Connect a channel</h3>
            <p class="mb-8 text-gray-400">To connect social media channels to this brand, click a button below. You'll be taken to their site to finish the authorization. Don't worry! You'll be right back.</p>
            <ul class="grid grid-cols-1 gap-5 sm:gap-6 sm:grid-cols-2 lg:grid-cols-4">
              <%= for channel <- remaining_channels(@channels) do %>
                <%= add_channel_card(channel, @active_brand.id) %>
              <% end %>
            </ul>
          </div>
        <% end %>
        <div class="mb-14 bg-white rounded-lg shadow-md p-8">
          <h3 class="border-b mb-4 pb-2 text-gray-600 text-xl">Danger Zone</h3>
          <p class="mb-4 text-gray-400">Deleting a brand is irreversable! Bordo will remove everything associated with the brand if deleted.</p>
          <button phx-click="delete-brand" phx-target="#settings-live" data-confirm="Are you sure you want to delete the brand <%= @active_brand.name %>?" class="rounded-md bg-red-500 hover:bg-red-400 transition transition-all duration-150 font-weight-bold px-4 py-2 text-white">Delete</button>
        </div>
        <div class="pin-b">
          <p class="text-xs text-center text-gray-500 mb-2">
            <%= System.get_env("RENDER_GIT_COMMIT", "dev") %>&nbsp;&nbsp;|&nbsp;&nbsp;&copy;<%= DateTime.utc_now.year %> Bordo, LLC&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://hellobordo.com/privacy-policy" class="text-gray-500 underline">Privacy Policy</a>
          </p>
        </div>
      </div>
    </div>
    """
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

  def handle_event("upload-success", params, socket) do
    brand = socket.assigns.active_brand

    case Brands.update_brand(brand, %{"image_url" => params["thumbnail_url"]}) do
      {:ok, %Brand{} = brand} ->
        {:noreply,
         assign(socket, active_brand: brand)
         |> put_flash(:success, "Your brand image is updated!")}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
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
    <li class="col-span-1 flex flex-col text-center bg-white rounded-lg shadow">
      <div class="flex-1 flex flex-col p-8 relative">
        <div x-data="{ open: false }" @keydown.window.escape="open = false" @click.away="open = false" class="absolute right-0 top-0 mt-3 mr-2">
          <div>
            <button @click="open = !open" type="button" class="p-2 bg-transparent text-sm leading-5 font-medium text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:bg-gray-50 active:text-gray-800 transition ease-in-out duration-150" id="options-menu" aria-haspopup="true" x-bind:aria-expanded="open">
              <%= feather_icon("chevron-down") %>
            </button>
          </div>

          <div x-show="open" x-description="Dropdown panel, show/hide based on dropdown state." x-transition:enter="transition ease-out duration-100" x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100" x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100" x-transition:leave-end="transform opacity-0 scale-95" class="origin-top-right absolute right-0 border w-56 rounded-md shadow-md" style="display: none;">
            <div class="py-1 rounded-md bg-white" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
              <a href="#" phx-click="delete-channel" phx-target="#settings-live" phx-value-channel_id="<%= channel.id %>" @click="open = !open" class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-blue-500 hover:text-white focus:outline-none focus:bg-blue-500 focus:text-white" role="menuitem" data-confirm="Are you sure? This will remove EVERYTHING associated with this channel.">Remove Channel</a>
            </div>
          </div>
        </div>
        <div class="mb-4 flex items-center w-full justify-center">
          <div class="w-10 h-10 mr-2">
            <%= card_logo(channel.network) %>
          </div>
          <%= feather_icon("link", "mr-2 text-gray-500") %>
          <div class="flex-shrink-0">
            <img class="h-12 w-12 rounded-full" src="<%= connection_url(channel) %>" alt="" />
          </div>
        </div>
        <%= card_resource_info(channel) %>
      </div>
      <%= if channel.network == "facebook" do %>
        <div class="-mt-px flex">
          <div class="w-0 flex-1 flex">
            <%= link to: Routes.facebook_path(BordoWeb.Endpoint, :reauth, %{"brand_id" => channel.brand_id}), class: "-mr-px bg-gray-50 border-gray-100 border-t duration-150 ease-in-out flex-1 focus:border-blue-300 focus:outline-none focus:shadow-outline-blue focus:z-10 font-medium hover:text-gray-500 inline-flex items-center justify-center py-2 relative rounded-bl-lg text-gray-700 text-sm transition w-0" do %>
              <%= feather_icon("refresh-cw") %>
              <span class="ml-3">Reauthorize</span>
            <% end %>
          </div>
        </div>
      <% end %>
    </li>
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
    <li class="col-span-1 flex shadow rounded-md">
      <div class="flex-1 flex items-center justify-between bg-white rounded-md truncate">
        <div class="flex-1 flex items-center content-center px-4 py-3 text-sm leading-5 truncate">
          <div class="mr-3">
            <%= card_logo(channel) %>
          </div>
          <h3 class="text-gray-900 font-medium text-base"><%= String.capitalize(channel) %></h3>
        </div>
        <div class="flex-shrink-0 pr-3">
          <span class="inline-flex rounded-md">
          <%= link(
            to: link,
            class:
              "inline-flex items-center px-2.5 py-1.5 bg-gray-50 text-xs leading-4 font-medium rounded text-gray-700 hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
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
