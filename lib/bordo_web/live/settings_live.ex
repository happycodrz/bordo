defmodule BordoWeb.SettingsLive do
  use BordoWeb, :live_component
  alias Bordo.Brands
  alias Bordo.Brands.Brand
  alias Bordo.Channels
  alias Bordo.Channels.Channel
  alias BordoWeb.Helpers.BrandHelper
  alias BordoWeb.Helpers.Svg

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

  def handle_event("edit-channel-label", %{"channel-id" => channel_id}, socket) do
    channel = Channels.get_channel!(channel_id)

    changeset = Channel.changeset(channel, %{})

    {:noreply,
     socket |> assign(:editing_channel, channel_id) |> assign(:channel_changeset, changeset)}
  end

  def handle_event("edit-channel-label", _params, socket) do
    {:noreply, socket |> assign(:editing_channel, nil)}
  end

  def handle_event("channel-save", params, socket) do
    channel = Channels.get_channel!(socket.assigns.editing_channel)

    case Channels.update_channel(channel, params["channel"]) do
      {:ok, channel} ->
        {:noreply,
         socket
         |> put_flash(:success, "Updated #{channel.label}")
         |> push_redirect(
           to: Routes.bordo_path(socket, :settings, socket.assigns.active_brand.slug)
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, :channel_changeset, changeset)}
    end
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
        {:noreply,
         assign(socket,
           active_brand: brand,
           changeset: Brand.changeset(socket.assigns.active_brand, params["brand"])
         )}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def channel_card(channel, assigns) do
    ~e"""
    <li>
      <div class="flex items-center px-4 py-4 sm:px-6">
        <div class="flex items-center mr-4">
          <%= status_lamp(channel) %>
        </div>
        <div class="min-w-0 flex-1 flex items-center">
          <div class="flex-shrink-0">
            <%= card_logo(channel.network) %>
          </div>
          <div class="min-w-0 flex-1 px-4">
            <div>
              <%= card_resource_info(channel, assigns[:editing_channel], assigns[:channel_changeset]) %>
            </div>
          </div>
        </div>
        <%= reauthenticate_button(channel) %>
        <div x-data="{ open: false }" @keydown.window.escape="open = false" @click.away="open = false" class="relative inline-block text-left">
          <button @click="open = !open" class="w-8 h-8 bg-white inline-flex items-center justify-center text-gray-400 rounded-full bg-transparent hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
            <span class="sr-only">Open options</span>
            <svg class="w-5 h-5" x-description="Heroicon name: dots-vertical" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
              <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z"></path>
            </svg>
          </button>

          <div x-show="open" x-description="Dropdown panel, show/hide based on dropdown state." x-transition:enter="transition ease-out duration-100" x-transition:enter-start="transform opacity-0 scale-95" x-transition:enter-end="transform opacity-100 scale-100" x-transition:leave="transition ease-in duration-75" x-transition:leave-start="transform opacity-100 scale-100" x-transition:leave-end="transform opacity-0 scale-95" class="z-10 origin-top-right absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5">
            <div class="py-1" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
              <a href="#" phx-click="delete-channel" phx-target="#settings-live" phx-value-channel_id="<%= channel.id %>" @click="open = !open" class="block px-4 py-2 text-sm leading-5 text-gray-700 hover:bg-blue-500 hover:text-white focus:outline-none focus:bg-blue-500 focus:text-white" role="menuitem" data-confirm="Are you sure? This will remove EVERYTHING associated with this channel.">Remove Channel</a>
            </div>
          </div>
        </div>
      </div>
    </li>
    """
  end

  defp status_lamp(%{needs_reauthentication: false}) do
    ~e"""
      <span class="bg-green-400 rounded-full block w-2 h-2 mr-2"></span>
    """
  end

  defp status_lamp(%{needs_reauthentication: true}) do
    ~e"""
      <span class="bg-red-600 rounded-full block w-2 h-2 mr-2"></span>
    """
  end

  def reauthenticate_button(channel) do
    ~e"""
    <%= if channel.needs_reauthentication do %>
      <div class="flex flex-1 mr-4">
        <div class="w-0 flex-1 flex">
          <%= link to: Routes.facebook_path(BordoWeb.Endpoint, :reauth, %{"brand_id" => channel.brand_id}), class: "inline-flex items-center px-2 py-2 border border-transparent shadow-sm text-sm font-small rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" do %>
            <%= feather_icon("refresh-cw") %>
            <span class="ml-3">Reauthorize</span>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  defp add_channel_card(channel_name, brand_id) do
    link =
      case channel_name do
        "twitter" ->
          Routes.twitter_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

        "facebook" ->
          Routes.facebook_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

        "linkedin" ->
          Routes.linkedin_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})

        "zapier" ->
          Routes.zapier_path(BordoWeb.Endpoint, :auth, %{"brand_id" => brand_id})
      end

    ~e"""
    <li class="col-span-1 flex shadow rounded-md">
      <div class="flex-1 flex items-center justify-between bg-white rounded-md truncate">
        <div class="flex-1 flex items-center content-center px-4 py-3 text-sm leading-5 truncate">
          <div class="mr-3">
            <%= card_logo(channel_name) %>
          </div>
          <h3 class="text-gray-900 font-medium text-base"><%= String.capitalize(channel_name) %></h3>
          <%= if channel_name == "zapier" do %>
            <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded text-xs font-medium leading-4 bg-blue-100 text-blue-800">
              Beta
            </span>
          <% end %>
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

    Enum.reject(networks, fn network ->
      Enum.member?(channel_networks, network) && network != "zapier"
    end)
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

      "zapier" ->
        Svg.social_icon("zapier", style: "fill: #2867b2; width: 2.5rem; height: 2.5rem;")

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

  defp connection_url(%Channel{network: "zapier"}) do
    Routes.static_path(BordoWeb.Endpoint, "/images/logo.svg")
  end

  defp card_resource_info(%Channel{network: "twitter"} = channel, _, _) do
    ~e"""
    <div>
      <div class="text-gray-800">
        <%= channel.resource_info["name"] %>
      </div>
    </div>
    """
  end

  defp card_resource_info(%Channel{network: "facebook"} = channel, _, _) do
    ~e"""
    <div class="text-gray-800">
      <%= channel.resource_info["name"] %>
    </div>
    """
  end

  defp card_resource_info(%Channel{network: "linkedin"} = channel, _, _) do
    ~e"""
    <div class="text-gray-800">
      <%= channel.resource_info["localizedName"] %>
    </div>
    """
  end

  defp card_resource_info(
         %Channel{network: "zapier"} = channel,
         editing_channel \\ nil,
         changeset
       ) do
    ~e"""
    <div>
      <div class="px-4 py-5 sm:p-0">
        <dl>
          <div class="sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6 sm:py-5">
            <dt class="text-sm leading-5 font-medium text-gray-500">
              Label
            </dt>
            <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2">
              <%= if editing_channel == channel.id do %>
                <%= f = form_for changeset, "#", [as: :channel, phx_submit: "channel-save", phx_target: "#settings-live"] %>
                  <div>
                      <%= text_input f, :label, class: "border-b border-dotted border-1", autocomplete: :off, placeholder: "No Name" %>
                      <%= error_tag f, :label %>
                  </div>

                  <div>
                    <span class="block w-full">
                      <span class="text-gray-700 cursor-pointer mr-2" phx-click="edit-channel-label" phx-target="#settings-live">Cancel</span>
                      <button type="submit"
                        class="py-2 text-blue-700"
                        phx-disable-with="Saving...">Save</button>
                    </span>
                  </div>
                </form>
              <% else %>
                <span phx-click="edit-channel-label" phx-value-channel-id="<%= channel.id %>" phx-target="#settings-live">
                  <span class="border-dotted border-b border-1 mr-2">
                    <%= if is_nil(channel.label) do %>
                      <i class="text-gray-400 cursor-pointer">No Label</i>
                    <% else %>
                      <%= channel.label %>
                    <% end %>
                  </span>
                  <%= feather_icon("edit-3", "text-gray-400 text-sm w-1 h-1 cursor-pointer") %>
                </span>
              <% end %>
            </dd>
          </div>
          <div class="mt-8 sm:mt-0 sm:grid sm:grid-cols-3 sm:gap-4 sm:border-t sm:border-gray-200 sm:px-6 sm:py-5">
            <dt class="text-sm leading-5 font-medium text-gray-500">
              Api Token
            </dt>
            <dd class="mt-1 text-sm leading-5 text-gray-900 sm:mt-0 sm:col-span-2">
              <%= channel.token %>
            </dd>
          </div>
        </dl>
      </div>
      <%= if Enum.empty?(channel.webhooks) do %>
        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4">
          <div class="flex">
            <div class="flex-shrink-0">
              <!-- Heroicon name: exclamation -->
              <svg class="h-5 w-5 text-yellow-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </div>
            <div class="ml-3">
              <p class="text-sm leading-5 text-yellow-700">
                All good here, but this channel isn't fully configured yet. Complete the configuration by <a href="https://zapier.com/app/editor?redirect=true" class="underline">creating a Zap</a>.
              </p>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
