defmodule BordoWeb.Admin.TeamsLive.Edit do
  use BordoWeb, :live_view
  alias BordoWeb.Router.Helpers, as: Routes

  alias Bordo.Brands
  alias Bordo.Teams
  alias BordoWeb.Admin.TeamView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %{})}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    team = Teams.get_team!(id)

    {:noreply,
     assign(socket, %{
       team: team,
       brands: Brands.list_brands_for_team(team.id),
       changeset: Teams.change_team(team)
     })}
  end

  def render(assigns), do: TeamView.render("edit.html", assigns)

  def handle_event("validate", %{"team" => params}, socket) do
    changeset =
      socket.assigns.team
      |> Teams.change_team(params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"team" => team_params}, socket) do
    case Teams.update_team(socket.assigns.team, team_params) do
      {:ok, _team} ->
        {:noreply,
         socket
         |> put_flash(:info, "Team updated successfully.")
         |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.TeamsLive.Index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete", %{"team_id" => team_id}, socket) do
    team = Teams.get_team!(team_id)
    {:ok, _team} = Teams.delete_team(team)

    {:noreply,
     socket
     |> put_flash(:info, "Team deleted successfully.")
     |> redirect(to: Routes.admin_live_path(socket, BordoWeb.Admin.TeamsLive.Index))}
  end
end
