defmodule BordoWeb.TeamSettingsLive do
  use BordoWeb, :live_component

  alias Bordo.Teams
  alias Bordo.Users.Account
  alias BordoWeb.Admin.UserView
  alias Stripe.BillingPortal.Session

  def render(assigns) do
    ~L"""
    <div class="p-8 bg-gray-50 min-h-full" id="team-settings-live-wrapper">
      <h2 class="mt-2 mb-8 text-3xl">Team Settings</h2>
      <div class="bg-white rounded-lg shadow-md p-8 mb-10">
        <h3 class="mb-3 text-xl">Timezone</h3>
        <%= f = form_for @team_changeset, "#", [phx_submit: :update_team, phx_target: "#team-settings-live-wrapper"] %>
          <div class="mt-6">
            <%= label f, :timezone, class: "block text-sm leading-5 font-medium text-gray-700" %>
            <%= timezone_select(f, :timezone, @team.timezone) %>
          </div>
          <div class="mt-6">
            <span class="rounded-md shadow">
              <button type="submit"
                class="flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out"
                phx-disable-with="Updating...">Save changes</button>
            </span>
          </div>
        </form>
      </div>

      <div class="bg-white rounded-lg shadow-md p-8 mb-10">
        <h3 class="mb-3 text-xl">Add Team Member</h3>
        <p class="text-gray-500 mb-4">To add a user to your team, type their email and a new password below. They'll receive an email letting them know they're in!<p>
        <%= f = form_for @changeset, "#", [phx_submit: :add_user, phx_target: "#team-settings-live-wrapper"] %>
          <div class="grid grid-cols-12 gap-3 mb-4">
            <div class="col-span-5">
              <%= text_input f, :email, class: "form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow focus:outline-none focus:shadow-outline-red focus:border-red-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", placeholder: "Email Address" %>
              <%= error_tag f, :email %>
              <%= hidden_input f, :team_id, value: @active_brand.team_id %>
            </div>
            <div class="col-span-5">
              <%= password_input f, :password, class: "form-input block w-full py-2 px-3 border border-gray-300 rounded-md shadow focus:outline-none focus:shadow-outline-red focus:border-red-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", placeholder: "Password" %>
              <%= error_tag f, :password %>
            </div>
            <div class="col-span-2">
              <%= submit "Add New User", phx_disable_with: "Adding...", class: "inline-flex justify-center py-2
              px-4 border-transparent text-sm leading-5 font-medium rounded-md text-white
              bg-red-500 hover:bg-red-400 focus:outline-none focus:border-red-500
              focus:shadow-outline-red active:bg-red-600 transition duration-150 ease-in-out w-100" %>
            </div>
          </div>
        </form>
      </div>
      <div class="bg-white rounded-lg shadow-md p-8 mb-8">
        <h3 class="mb-3 text-xl">Your Team</h3>
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

      <h2 class="mt-2 mb-8 text-3xl">Billing</h2>
      <div class="bg-white shadow sm:rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900">
            Payment method
          </h3>
          <%= if Enum.any?(@payment_methods.data) do %>
            <div class="mt-5">
              <div class="rounded-md bg-gray-50 px-6 py-5 sm:flex sm:items-start sm:justify-between">
                <div class="sm:flex sm:items-start">
                  <%= card_icon((@payment_methods.data |> Enum.at(0)).card.brand) %>
                  <div class="mt-3 sm:mt-0 sm:ml-4">
                    <div class="text-sm leading-5 font-medium text-gray-900">
                      Ending with <%= (@payment_methods.data |> Enum.at(0)).card.last4 %>
                    </div>
                    <div class="mt-1 text-sm leading-5 text-gray-600 sm:flex sm:items-center">
                      <div>
                        Expires <%= card_expiry(Enum.at(@payment_methods.data, 0)) %>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="mt-4 sm:mt-0 sm:ml-6 sm:flex-shrink-0">
                  <span class="inline-flex rounded-md shadow-sm">
                    <button type="button" phx-click="manage-billing-clicked" phx-target="#team-settings-live-wrapper" phx-disable-with="Redirecting..." class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm leading-5 font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150">
                      Edit
                    </button>
                  </span>
                </div>
              </div>
            </div>
          <% else %>
          <div class="mt-5">
            <div class="rounded-md bg-gray-50 px-6 py-5 sm:flex items-center sm:justify-between">
              <div class="sm:flex sm:items-start">
                No payment method added yet
              </div>
              <div class="mt-4 sm:mt-0 sm:ml-6 sm:flex-shrink-0">
                <span class="inline-flex rounded-md shadow-sm">
                  <button type="button" phx-click="manage-billing-clicked" phx-target="#team-settings-live-wrapper" phx-disable-with="Redirecting..." class="inline-flex items-center px-4 py-2 border border-transparent text-base leading-6 font-medium rounded-md text-white bg-red-500 hover:bg-red-500 focus:outline-none focus:border-red-700 focus:shadow-outline-red active:bg-red-700 transition ease-in-out duration-150">
                    Manage billing
                    <%= feather_icon("arrow-right", "w-2 h-2 ml-2") %>
                  </button>
                </span>
              </div>
            </div>
          </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("manage-billing-clicked", _params, socket) do
    {:ok, session} =
      Session.create(%{
        customer: socket.assigns.team.stripe_customer_id,
        return_url: Application.fetch_env!(:bordo, :stripe)[:redirect_success]
      })

    {:noreply, redirect(socket, external: session.url)}
  end

  def handle_event("add_user", %{"user" => user_params}, socket) do
    case Account.create_user_with_auth0(user_params) do
      {:ok, user} ->
        {:noreply, socket |> assign(users: [socket.assigns.users | user])}

      {:error, changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def handle_event("update_team", %{"team" => team_params}, socket) do
    case Teams.update_team(socket.assigns.team, team_params) do
      {:ok, team} ->
        {:noreply, socket |> assign(team: team) |> put_flash(:success, "Team updated!")}

      {:error, changeset} ->
        {:noreply, socket |> assign(team_changeset: changeset)}
    end
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

  defp card_icon("visa") do
    ~e"""
    <svg class="h-8 w-auto sm:flex-shrink-0 sm:h-6" fill="none" viewBox="0 0 36 24" role="img" aria-labelledby="svg-visa">
      <title id="svg-visa">VISA</title>
      <rect width="36" height="24" fill="#224DBA" rx="4" />
      <path fill="#fff" fill-rule="evenodd" d="M10.925 15.673H8.874l-1.538-6c-.073-.276-.228-.52-.456-.635A6.575 6.575 0 005 8.403v-.231h3.304c.456 0 .798.347.855.75l.798 4.328 2.05-5.078h1.994l-3.076 7.5zm4.216 0h-1.937L14.8 8.172h1.937l-1.595 7.5zm4.101-5.422c.057-.404.399-.635.798-.635a3.54 3.54 0 011.88.346l.342-1.615A4.808 4.808 0 0020.496 8c-1.88 0-3.248 1.039-3.248 2.481 0 1.097.969 1.673 1.653 2.02.74.346 1.025.577.968.923 0 .519-.57.75-1.139.75a4.795 4.795 0 01-1.994-.462l-.342 1.616a5.48 5.48 0 002.108.404c2.108.057 3.418-.981 3.418-2.539 0-1.962-2.678-2.077-2.678-2.942zm9.457 5.422L27.16 8.172h-1.652a.858.858 0 00-.798.577l-2.848 6.924h1.994l.398-1.096h2.45l.228 1.096h1.766zm-2.905-5.482l.57 2.827h-1.596l1.026-2.827z" clip-rule="evenodd" />
    </svg>
    """
  end

  defp card_icon("master") do
    ~e"""
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 131.39 86.9"><defs><style>.a{opacity:0;}.b{fill:#fff;}.c{fill:#ff5f00;}.d{fill:#eb001b;}.e{fill:#f79e1b;}</style></defs><title>Master</title><g class="a"><rect class="b" width="131.39" height="86.9"/></g><rect class="c" x="48.37" y="15.14" width="34.66" height="56.61"/><path class="d" d="M51.94,43.45a35.94,35.94,0,0,1,13.75-28.3,36,36,0,1,0,0,56.61A35.94,35.94,0,0,1,51.94,43.45Z"/><path class="e" d="M120.5,65.76V64.6H121v-.24h-1.19v.24h.47v1.16Zm2.31,0v-1.4h-.36l-.42,1-.42-1h-.36v1.4h.26V64.7l.39.91h.27l.39-.91v1.06Z"/><path class="e" d="M123.94,43.45a36,36,0,0,1-58.25,28.3,36,36,0,0,0,0-56.61,36,36,0,0,1,58.25,28.3Z"/></svg>
    """
  end

  defp card_icon(_) do
    ~e"""
      <%= feather_icon("credit-card") %>
    """
  end

  defp card_expiry(payment_data) do
    "#{String.pad_leading(Integer.to_string(payment_data.card.exp_month), 2, "0")}/#{
      payment_data.card.exp_year
    }"
  end
end
