defmodule BordoWeb.Oauth.FacebookLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Brands
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def render(assigns) do
    ~L"""
    <%= if @error do %>
      There was a problem connecting to Facebook. Please try again.
    <% else %>
      <h2>Choose a Page or Profile</h2>
      <p>Select the Facebook profile or organization you want to post as:</p>
      <ul>
        <%= for org <- @orgs do %>
          <li>
            <a href="#" phx-click="org-selected" phx-value-org_id="<%= org["id"] %>">
              <%= org["name"] %>
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

    {:ok, socket |> assign(orgs: [], brand_id: brand_id, error: nil)}
  end

  def handle_info({:fetch_orgs, code}, socket) do
    with {:ok, %{"access_token" => access_token}} <- get_access_token(code),
         {:ok, %{"access_token" => long_lived_token}} <- upgrade_access_token(access_token),
         {:ok, accounts} <- Facebook.my_accounts(access_token) do
      {:noreply, assign(socket, orgs: accounts["data"], access_token: long_lived_token)}
    else
      {:error, err} ->
        {:noreply, assign(socket, orgs: [], error: err)}
    end
  end

  def handle_event("org-selected", %{"org_id" => org_id}, socket) do
    brand = Brands.get_brand!(socket.assigns.brand_id)

    {:ok, resource_info} =
      Facebook.page(org_id, socket.assigns.access_token, ["id", "picture", "name"])

    channel_params = %{
      "token" => socket.assigns.access_token,
      "network" => "facebook",
      "resource_id" => org_id,
      "resource_info" => resource_info,
      "brand_id" => brand.id
    }

    case Channels.create_channel(channel_params) do
      {:ok, %Channel{} = channel} ->
        {:noreply,
         redirect(socket, to: Routes.live_path(socket, BordoWeb.SettingsLive, brand.slug))}

      _ ->
        {:noreply, socket}
    end
  end

  defp get_access_token(code) do
    Facebook.access_token(
      System.get_env("FACEBOOK_APP_ID"),
      System.get_env("FACEBOOK_APP_SECRET"),
      System.get_env("FACEBOOK_REDIRECT_URI"),
      code
    )
  end

  defp upgrade_access_token(access_token) do
    Facebook.long_lived_access_token(
      System.get_env("FACEBOOK_APP_ID"),
      System.get_env("FACEBOOK_APP_SECRET"),
      access_token
    )
  end
end
