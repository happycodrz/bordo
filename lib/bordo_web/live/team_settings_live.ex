defmodule BordoWeb.TeamSettingsLive do
  use BordoWeb, :client_live_view

  alias Bordo.Brands
  alias Bordo.Users
  alias Bordo.Users.Account
  alias Bordo.Users.User
  alias BordoWeb.Admin.UserView

  def mount(%{"brand_slug" => brand_slug}, _session, socket) do
    active_brand = Brands.get_brand!(slug: brand_slug)

    {:ok,
     assign(socket,
       active_brand: active_brand,
       nav_item: nil,
       users: fetch_users(active_brand.team_id),
       changeset: User.changeset(%User{}, %{})
     )}
  end

  def render(assigns) do
    ~L"""
    <div class="p-8">
      <div class="bg-white rounded-lg shadow p-8">
      <h3>Team Members</h3>
      <%= f = form_for @changeset, "#", [phx_submit: :add_user, class: "mb-8"] %>
        <div class="grid grid-cols-12 gap-6 mb-4">
          <div class="col-span-4 sm:col-span-3">
            <%= label f, :email, class: "block text-sm font-medium leading-5 text-gray-700" %>
            <%= text_input f, :email, class: "mt-1 form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5" %>
            <%= error_tag f, :email %>
            <%= hidden_input f, :team_id, value: @active_brand.team_id %>
          </div>
          <div class="col-span-4 sm:col-span-3">
            <%= label f, :password, class: "block text-sm font-medium leading-5 text-gray-700" %>
            <%= password_input f, :password, class: "mt-1 form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5" %>
            <%= error_tag f, :password %>
          </div>
        </div>
        <span class="inline-flex rounded-md shadow-sm">
          <%= submit "Save", phx_disable_with: "Saving...", class: "inline-flex justify-center py-2
          px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white
          bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700
          focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out" %>
        </span>
      </form>
      <%= for user <- @users do %>
        <%= user_row(user) %>
      <% end %>
    </div>
    </div>
    """
  end

  def handle_event("add_user", %{"user" => user_params}, socket) do
    case Account.create_user_with_auth0(user_params) do
      {:ok, user} ->
        {:noreply, socket |> assign(users: [socket.assigns.users | user])}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp fetch_users(team_id) do
    Users.list_users_for_team(team_id)
  end

  defp user_row(user) do
    ~e"""
    <div class="flex items-center">
      <div class="flex-shrink-0 h-10 w-10 mr-6">
        <img class="h-10 w-10 rounded-full" src="<%= UserView.avatar(user) %>" alt="" />
      </div>
      <div class="flex items-center">
        <div>
          <span>Kevin Brown</span>
          <span><%= user.email %></span>
        </div>
      </div>
    </div>
    """
  end
end
