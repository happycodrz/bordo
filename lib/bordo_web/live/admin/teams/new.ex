defmodule BordoWeb.Admin.TeamsLive.New do
  use BordoWeb, :live_view
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Teams
  alias Bordo.Teams.Team

  def mount(_params, _session, socket) do
    changeset = Teams.change_team(%Team{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def render(assigns), do: Phoenix.View.render(BordoWeb.Admin.TeamView, "new.html", assigns)

  def handle_event("validate", %{"team" => team_params}, socket) do
    changeset =
      %Team{}
      |> Teams.change_team(team_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    case Teams.create_team(team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "team created")
         |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.TeamsLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
