defmodule BordoWeb.Admin.Select do
  use BordoWeb, :live_component
  alias Bordo.Teams
  import Phoenix.HTML.Form

  defp teams do
    Teams.list_teams() |> Enum.sort_by(& &1.name) |> Enum.map(fn team -> {team.name, team.id} end)
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:teams, teams())
      |> assign(:team, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <div phx-update="ignore">
        <%= select(assigns.form, :team_id, teams(), class: "js-choice") %>
      </div>
    """
  end
end
