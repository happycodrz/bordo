defmodule BordoWeb.OnboardingLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Brands.Brand
  alias Bordo.Teams.Team
  alias Bordo.{Brands, Teams}
  alias Bordo.Users
  alias BordoWeb.Live.AuthHelper

  def render(%{step: :create_team} = assigns) do
    ~L"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 class="mt-6 text-center text-3xl leading-9 font-extrabold text-gray-900 mb-6">Create a team</h2>
        <p class="text-gray-600">If you want to join a team, stop here and request access from the team's owner.</p>
      </div>
      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <%= f = form_for @changeset, "#", [as: :team, phx_submit: "save"] %>
          <div>
            <%= label f, :name, "Team Name", class: "block text-sm font-medium leading-5 text-gray-700" %>
            <div class="mt-1 rounded-md shadow-sm">
              <%= text_input f, :name, class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
              <%= error_tag f, :name %>
            </div>
          </div>

          <div class="mt-6">
            <span class="block w-full rounded-md shadow-sm">
              <button type="submit"
                class="w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out"
                phx-disable-with="Saving...">Create my team</button>
            </span>
          </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  def render(%{step: :create_brand} = assigns) do
    ~L"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <h2 class="mt-6 text-center text-3xl leading-9 font-extrabold text-gray-900 mb-6">Create a brand</h2>
        <p class="text-gray-600">Don't worry, you can change this later.</p>
      </div>
      <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
        <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
          <%= f = form_for @changeset, "#", [as: :brand, phx_submit: "save"] %>
          <div>
            <%= label f, :name, "Brand Name", class: "block text-sm font-medium leading-5 text-gray-700" %>
            <div class="mt-1 rounded-md shadow-sm">
              <%= text_input f, :name, class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
              <%= error_tag f, :name %>
            </div>
          </div>

          <div class="mt-6">
            <span class="block w-full rounded-md shadow-sm">
              <button type="submit"
                class="w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:border-indigo-700 focus:shadow-outline-indigo active:bg-indigo-700 transition duration-150 ease-in-out"
                phx-disable-with="Adding brand...">Add a brand</button>
            </span>
          </div>
          </form>
        </div>
      </div>
    </div>
    """
  end

  # TODO: Fix this garbage with a plug. This is just to handle nil brands or redirect to the "first" brand
  # from the router, which will direct here if a route is not found...
  def mount(_params, session, socket) do
    {:ok, user} = AuthHelper.load_user(session)

    if user.team_id != nil do
      brands = Brands.list_brands_for_team(user.team_id)

      if Enum.any?(brands) do
        brand = Enum.at(brands, 0)
        {:ok, redirect(socket, to: Routes.live_path(socket, BordoWeb.LaunchpadLive, brand.slug))}
      else
        {:ok, determine_step(socket, user)}
      end
    else
      {:ok, determine_step(socket, user)}
    end
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    user_id = socket.assigns.current_user.user_id

    case Teams.create_team(
           team_params
           |> Enum.into(%{"owner_id" => user_id})
         ) do
      {:ok, team} ->
        user = Users.get_user!(user_id)
        {:ok, updated_user} = Users.update_user(user, %{team_id: team.id})

        {:noreply, determine_step(socket, updated_user)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def handle_event("save", %{"brand" => brand_params}, socket) do
    case Brands.create_brand(
           brand_params
           |> Enum.into(%{
             "owner_id" => socket.assigns.current_user.id,
             "team_id" => socket.assigns.current_user.team_id
           })
         ) do
      {:ok, brand} ->
        {:noreply,
         redirect(socket,
           to: Routes.live_path(BordoWeb.Endpoint, BordoWeb.LaunchpadLive, brand.slug)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  defp determine_step(socket, user) do
    if user.team_id == nil do
      assign(socket,
        team: nil,
        errors: nil,
        current_user: user,
        step: :create_team,
        skip_flash: true,
        changeset: Team.changeset(%Team{}, %{})
      )
    else
      assign(socket,
        team: nil,
        errors: nil,
        current_user: user,
        step: :create_brand,
        skip_flash: true,
        changeset: Brand.changeset(%Brand{}, %{})
      )
    end
  end
end
