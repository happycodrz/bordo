defmodule BordoWeb.Oauth.LinkedInLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def render(assigns) do
    ~L"""
    <%= if connected?(@socket) do %>
      <div x-data="{ oauthComplete: <%= @success %> }"
          x-bind:oauthComplete="<%= @success %>"
          x-init="$watch('oauthComplete', (value) => {
            if (value == true) {
              if (window.opener) {
                window.opener.postMessage({
                    type: 'oAuthComplete',
                    queryString: window.location.search
                }, window.location.origin)
                window.opener.location = '/'
            }
            window.close()
            }
          })">
      </div>
    <% end %>
    <%= if @error do %>
      There was a problem connecting to Linkedin. Please try again.
    <% else %>
      <h2>Choose a Page or Profile</h2>
      <p>Select the LinkedIn profile or organization you want to post as:</p>
      <ul>
        <%= for org <- @orgs do %>
          <li>
            <a href="#" phx-click="org-selected" phx-value-org_id="<%= org["$URN"] %>">
              <%= org["localizedName"] %>
            </a>
          </li>
        <% end %>
      </ul>
    <% end %>
    """
  end

  def mount(params, session, socket) do
    %{"code" => code, "state" => state} = params
    %{"brand_id" => brand_id} = URI.decode_query(state)
    send(self(), {:fetch_orgs, code})
    {:ok, socket |> assign(orgs: [], brand_id: brand_id, error: nil, success: false)}
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
    channel_params = %{
      "token" => socket.assigns.access_token,
      "network" => "linkedin",
      "resource_id" => org_id,
      "brand_id" => socket.assigns.brand_id
    }

    case Channels.create_channel(channel_params) do
      {:ok, %Channel{} = channel} ->
        {:noreply, assign(socket, success: true)}

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
