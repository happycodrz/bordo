defmodule BordoWeb.OnboardingLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Brands.Brand
  alias Bordo.Teams.Team
  alias Bordo.{Brands, Teams, Users}
  alias BordoWeb.Helpers.BrandHelper
  alias BordoWeb.Live.AuthHelper

  @steps [:create_team, :create_brand]
  @step_text ["Create your team", "Add brands"]

  def render(assigns) do
    ~L"""
    <div class="h-screen flex bg-gray-50">
      <div class="flex flex-col w-1/3">
        <div class="flex flex-col h-0 flex-1 bg-gray-800 items-center justify-content-center">
          <div class="flex-1 flex flex-col pt-5 pb-4 overflow-y-auto">
            <nav class="mt-5 flex-1 px-2 bg-gray-800 space-y-1 flex items-center">
              <nav>
                <ul class="overflow-hidden">
                  <%= step(@step) %>
                </ul>
              </nav>
            </nav>
          </div>
        </div>
      </div>
      <div class="flex w-full items-center justify-center">
        <div class="sm:w-full md:w-full lg:w-2/3 2xl:w-1/3 max-w-6xl">
          <%= step_content(assigns) %>
        </div>
      </div>
    </div>
    """
  end

  def step(current_step) do
    @steps
    |> Enum.with_index()
    |> Enum.map(fn {_step, index} ->
      step_text = Enum.at(@step_text, index)

      case step_sign(current_step, index) do
        :negative ->
          step_incomplete(step_text)

        :positive ->
          step_completed(step_text)

        :equal ->
          step_current(index, step_text)
      end
    end)
  end

  def step_sign(current_step, index) do
    step_index = Enum.find_index(@steps, fn x -> x == current_step end)
    x = step_index - index

    cond do
      x == 0 ->
        :equal

      x < 0 ->
        :negative

      x > 0 ->
        :positive
    end
  end

  def last_step?(step_number) do
    step_number == length(@steps) - 1
  end

  def step_completed(text) do
    ~e"""
    <li class="relative pb-10">
      <div class="-ml-px absolute mt-0.5 top-4 left-4 w-0.5 h-full bg-blue-500"></div>
      <a href="#" class="relative flex items-center space-x-4 group focus:outline-none">
        <div class="h-9 flex items-center">
          <span class="relative z-10 w-8 h-8 flex items-center justify-center bg-blue-600 rounded-full group-hover:bg-blue-800 group-focus:bg-blue-800 transition ease-in-out duration-150">
            <svg class="w-5 h-5 text-white" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </span>
        </div>
        <div class="min-w-0">
          <h3 class="text-xs leading-4 font-semibold uppercase tracking-wide text-white"><%= text %></h3>
        </div>
      </a>
    </li>
    """
  end

  def step_current(step_number, text) do
    ~e"""
    <li class="relative pb-10">
      <%= unless last_step?(step_number) do %>
        <div class="-ml-px absolute mt-0.5 top-4 left-4 w-0.5 h-full bg-gray-300"></div>
      <% end %>
      <div class="relative flex items-center space-x-4 group focus:outline-none">
        <div class="h-9 flex items-center">
          <span class="relative z-10 w-8 h-8 flex items-center justify-center bg-white border-2 border-blue-600 rounded-full">
            <span class="h-2.5 w-2.5 bg-blue-600 rounded-full"></span>
          </span>
        </div>
        <div class="min-w-0">
          <h3 class="text-xs leading-4 font-semibold uppercase tracking-wide text-blue-400"><%= text %></h3>
        </div>
      </div>
    </li>
    """
  end

  def step_incomplete(text) do
    ~e"""
    <li class="relative">
      <a href="#" class="relative flex items-center space-x-4 group focus:outline-none">
        <div class="h-9 flex items-center">
          <span class="relative z-10 w-8 h-8 flex items-center justify-center bg-white border-2 border-gray-300 rounded-full group-hover:border-gray-400 group-focus:border-gray-400 transition ease-in-out duration-150">
            <span class="h-2.5 w-2.5 bg-transparent rounded-full group-hover:bg-gray-300 group-focus:bg-gray-300 transition ease-in-out duration-150"></span>
          </span>
        </div>
        <div class="min-w-0">
          <h3 class="text-xs leading-4 font-semibold uppercase tracking-wide text-gray-400"><%= text %></h3>
        </div>
      </a>
    </li>
    """
  end

  def step_content(%{step: :create_team} = assigns) do
    ~L"""
    <div class="p-4">
      <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <div>
          <h3 class="text-lg leading-6 font-medium text-gray-900">
            Create your team
          </h3>
          <p class="mt-1 text-sm leading-5 text-gray-500">
            Teams are the homebase. Next, you will add brands to this team.
          </p>
        </div>
        <%= f = form_for @changeset, "#", [as: :team, phx_submit: "save"] %>
        <div class="mt-6">
          <%= label f, :name, "Team Name", class: "block text-sm font-medium leading-5 text-gray-700" %>
          <div class="mt-1 rounded-md shadow">
            <%= text_input f, :name, placeholder: "Dunder Mifflin", class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
          </div>
          <%= error_tag f, :name %>
          <p class="mt-2 text-sm text-gray-500">If you want to join a team, stop here and request access from the team's owner.</p>
        </div>
        <div class="mt-6">
          <%= label f, :timezone, class: "block text-sm leading-5 font-medium text-gray-700" %>
          <%= select f, :timezone, Tzdata.zone_list |> Enum.filter(&(&1 == "America/Chicago")), selected: "America/Chicago", class: "mt-1 form-select block w-full pl-3 pr-10 py-2 text-base leading-6 border-gray-300 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 sm:text-sm sm:leading-5" %>
        </div>
        <div class="mt-6">
          <span class="block w-full rounded-md shadow">
            <button type="submit"
              class="w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out"
              phx-disable-with="Validating...">Create my team</button>
          </span>
        </div>
        </form>
      </div>
    </div>
    """
  end

  def step_content(%{step: :create_brand} = assigns) do
    ~L"""
    <div class="p-4">
      <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
        <div>
          <h3 class="text-lg leading-6 font-medium text-gray-900">
            Add Brands
          </h3>
          <p class="mt-1 text-sm leading-5 text-gray-500">
            You just need to add a single brand to start. You can easily add more later.
          </p>
        </div>
        <div class="mt-6">
          <%= f = form_for @changeset, "#", [as: :brand, phx_submit: "save"] %>
          <div>
            <%= label f, :name, "Brand Name", class: "block text-sm font-medium leading-5 text-gray-700" %>
            <div class="mt-1 rounded-md shadow">
              <%= text_input f, :name, placeholder: "Scranton Branch", class: "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm sm:leading-5", autocomplete: :off %>
            </div>
            <%= error_tag f, :name %>
          </div>

          <div class="mt-6">
            <span class="rounded-md shadow">
              <button type="submit"
                class="flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out"
                phx-disable-with="Validating...">Add a brand</button>
            </span>
          </div>
          </form>
          <%= if Enum.any?(@brands) do %>
            <%= brand_table(@brands) %>
          <% end %>
        </div>
      </div>
      <%= if Enum.any?(@brands) do %>
        <div class="mt-6">
          <button type="submit"
                  class="w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-500 focus:outline-none focus:border-blue-700 focus:shadow-outline-blue active:bg-blue-700 transition duration-150 ease-in-out"
                  phx-click="finish-onboarding"
                  phx-disable-with="Woo!">I'm all done adding brands &rarr;</button>
        </div>
      <% end %>
    </div>
    """
  end

  def brand_table(brands) do
    ~e"""
      <ul class="mt-8 grid grid-cols-1 gap-5 sm:gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <%= for brand <- brands do %>
          <li class="col-span-1 flex shadow rounded-md">
            <div class="flex-shrink-0 flex items-center justify-center w-16 bg-red-500 text-white text-sm leading-5 font-medium rounded-l-md">
              <%= BrandHelper.brand_letters(brand) %>
            </div>
            <div class="flex-1 flex items-center justify-between border-t border-r border-b border-gray-200 bg-white rounded-r-md truncate">
              <div class="flex-1 px-4 py-2 text-sm leading-5 truncate">
                <%= brand.name %>
              </div>
            </div>
          </li>
        <% end %>
      </ul>
    """
  end

  # TODO: Fix this garbage with a plug. This is just to handle nil brands or redirect to the "first" brand
  # from the router, which will direct here if a route is not found...
  def mount(_params, session, socket) do
    {:ok, user} = AuthHelper.load_user(session)

    team =
      if is_nil(user.team_id) do
        nil
      else
        Teams.get_team!(user.team_id)
      end

    brands = fetch_brands(user.team_id)

    case [!is_nil(team) && team.completed_onboarding, Enum.any?(brands)] do
      [true, true] -> {:ok, redirect(socket, to: home_path(socket, brands))}
      [false, true] -> {:ok, determine_step(assign(socket, brands: brands, team: team), user)}
      [_, _] -> {:ok, determine_step(socket, user)}
    end
  end

  def home_path(socket, brands) do
    brand = Enum.at(brands, 0)
    Routes.live_path(socket, BordoWeb.LaunchpadLive, brand.slug)
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

        {:noreply, determine_step(assign(socket, :team, team), updated_user)}

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
        {:noreply, socket |> assign(:brands, Enum.concat(socket.assigns.brands, [brand]))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(changeset: changeset)}
    end
  end

  def handle_event("finish-onboarding", _data, socket) do
    brand = Enum.at(socket.assigns.brands, 0)
    Teams.update_team(socket.assigns.team, %{completed_onboarding: true})
    {:noreply, redirect(socket, to: Routes.live_path(socket, BordoWeb.LaunchpadLive, brand.slug))}
  end

  defp fetch_brands(nil), do: []

  defp fetch_brands(team_id) do
    Brands.list_brands_for_team(team_id)
  end

  defp determine_step(socket, user) do
    if user.team_id == nil do
      assign(socket,
        team: nil,
        errors: nil,
        current_user: user,
        step: :create_team,
        skip_flash: true,
        changeset: Team.changeset(%Team{}, %{}),
        brands: socket.assigns[:brands] || []
      )
    else
      assign(socket,
        errors: nil,
        current_user: user,
        step: :create_brand,
        skip_flash: true,
        changeset: Brand.changeset(%Brand{}, %{}),
        brands: socket.assigns[:brands] || []
      )
    end
  end
end
