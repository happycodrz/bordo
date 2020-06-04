defmodule BordoWeb.ReactLive do
  use BordoWeb, :live_view

  alias Bordo.Brands
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  @impl true
  def render(assigns) do
    ~L"""
    <div class="h-screen flex">
      <%= live_component(@socket, BordoWeb.BrandNav, assigns) %>
      <div class="w-full">
        <div phx-update="ignore" id="root" class="w-full"></div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, session, socket) do
    %{"brand_id" => current_brand_id} = params
    {:ok, current_identity} = AuthHelper.load_user(session)
    current_user = Users.get_user!(current_identity.user_id)

    {:ok,
     assign(socket,
       show_modal: false,
       brands: fetch_brands(current_identity.team_id),
       current_brand_id: current_brand_id,
       current_identity: current_identity,
       current_user: current_user
     )}
  end

  defp fetch_brands(team_id) do
    Brands.list_brands_for_team(team_id)
  end
end
