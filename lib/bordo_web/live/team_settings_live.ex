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
      <h2 class="mt-2 mb-8">Team Settings</h2>
      <div class="bg-white rounded-lg shadow p-8 mb-10">
        <h3 class="mb-3">Add Team Member</h3>
        <p class="text-gray-500 mb-4">To add a user to your team, type their email and a new password below. They'll receive an email letting them know they're in!<p>
        <%= f = form_for @changeset, "#", [phx_submit: :add_user] %>
          <div class="grid grid-cols-12 gap-3 mb-4">
            <div class="col-span-5">
              <%= text_input f, :email, class: "form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:shadow-outline-red focus:border-red-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", placeholder: "Email Address" %>
              <%= error_tag f, :email %>
              <%= hidden_input f, :team_id, value: @active_brand.team_id %>
            </div>
            <div class="col-span-5">
              <%= password_input f, :password, class: "form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:shadow-outline-red focus:border-red-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", placeholder: "Password" %>
              <%= error_tag f, :password %>
            </div>
            <div class="col-span-2">
              <%= submit "Add New User", phx_disable_with: "Adding...", class: "inline-flex justify-center py-2
              px-4 border border-transparent text-sm leading-5 font-medium rounded-md text-white
              bg-red-500 hover:bg-red-600 focus:outline-none focus:border-red-500
              focus:shadow-outline-red active:bg-red-600 transition duration-150 ease-in-out w-100" %>
            </div>
          </div>
        </form>
      </div>
      <div class="bg-white rounded-lg shadow p-8">
        <h3 class="mb-3">Your Team</h3>
        <table class="table">
          <thead>
            <th>Name</th>
            <th>Email</th>
          </thead>
          <tbody>
            <%= for user <- @users do %>
              <%= user_row(user) %>
            <% end %>
          </tbody>
        </table>
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
    <tr>
      <td>
        <img class="inline-block h-8 w-8 rounded-full mr-3" src="<%= UserView.avatar(user) %>" alt="" />
        <strong><%= user.first_name %> <%= user.last_name %></strong>
      </td>
      <td>
        <a href="mailto:<%= user.email %>" target="_blank"><%= user.email %></a>
      </td>
    </tr>
    """
  end
end
