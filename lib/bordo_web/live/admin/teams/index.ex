defmodule BordoWeb.Admin.TeamsLive.Index do
  use BordoWeb, :live_view

  alias Bordo.Teams

  @impl true
  def render(assigns), do: BordoWeb.Admin.TeamView.render("index.html", assigns)

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Teams.subscribe()

    {:ok, assign(socket, teams: Teams.list_teams())}
  end

  @impl true
  def handle_info({Teams, [:team | _], _}, socket) do
    {:noreply, fetch(socket)}
  end

  defp fetch(socket) do
    teams = Teams.list_teams()
    assign(socket, teams: teams)
  end
end
