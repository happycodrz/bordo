defmodule BordoWeb.Oauth.LinkedInLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Brands
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def render(assigns) do
    ~L"""
    <%= if @error do %>
      <p class="bg-red-100 border-l-4 border-red-600 m-10 p-5 text-red-600">There was a problem connecting to LinkedIn. Please try again.</>
    <% else %>
      <div class="container mx-auto">
        <h2 class="mb-2 mt-15 text-4xl">Choose a Page or Profile</h2>
        <p class="mb-5 text-gray-500 text-lg tracking-wide">Select the LinkedIn profile or organization you want to post as:</p>
        <div class="gap-4 grid grid-cols-2">
          <%= for org <- @orgs do %>
            <a href="#" phx-click="org-selected" phx-value-org_id="<%= org["$URN"] %>" class="block duration-150 hover:shadow-md hover:text-gray-900 p-8 rounded-lg shadow text-gray-600 text-xl transition transition-all">
              <%= org["localizedName"] %>
            </a>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  def mount(params, _session, socket) do
    %{"code" => code, "state" => state} = params
    %{"brand_id" => brand_id} = URI.decode_query(state)
    send(self(), {:fetch_orgs, code})

    {:ok, socket |> assign(orgs: [], brand_id: brand_id, error: nil)}
  end

  def handle_info({:fetch_orgs, code}, socket) do
    with {:ok, %{"access_token" => access_token}} <- Linkedin.access_token(code),
         {:ok, companies} <- Linkedin.list_companies(access_token),
         {:ok, orgs} <- orgs(companies, access_token) do
      {:noreply, assign(socket, orgs: orgs, access_token: access_token)}
    else
      {:ok, %{"error" => err}} ->
        {:noreply, assign(socket, orgs: [], error: err)}

      {:ok, err} ->
        {:noreply, assign(socket, orgs: [], error: err)}
    end
  end

  def handle_event("org-selected", %{"org_id" => "urn:li:organization:" <> org_id}, socket) do
    brand = Brands.get_brand!(socket.assigns.brand_id)
    resource_info = Linkedin.get_organization(socket.assigns.access_token, org_id)

    channel_params = %{
      "token" => socket.assigns.access_token,
      "network" => "linkedin",
      "resource_id" => org_id,
      "resource_info" => resource_info,
      "brand_id" => brand.id
    }

    case Channels.create_channel(channel_params) do
      {:ok, %Channel{} = _channel} ->
        {:noreply,
         redirect(socket, to: Routes.live_path(socket, BordoWeb.SettingsLive, brand.slug))}

      _ ->
        {:noreply, socket}
    end
  end

  defp orgs(companies, access_token) do
    orgs =
      Enum.map(companies["elements"], fn org ->
        %{"organizationalTarget" => "urn:li:organization:" <> org_id} = org
        Linkedin.get_organization(access_token, org_id)
      end)

    {:ok, orgs}
  end
end
