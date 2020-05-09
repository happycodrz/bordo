defmodule BordoWeb.Admin.Select do
  use BordoWeb, :live_component
  alias Bordo.{Teams, Users}
  import Phoenix.HTML.Form

  def render(%{selection: "admin_list_users"} = assigns) do
    selection = admin_list_users()
    render_select(assigns, :owner_id, selection)
  end

  def render(%{selection: "admin_list_teams"} = assigns) do
    selection = teams()
    render_select(assigns, :team_id, selection)
  end

  defp render_select(assigns, form_for, selection) do
    ~L"""
      <%= select(assigns.form, form_for, selection, class: "js-choice") %>
    """
  end

  defp teams do
    Teams.list_teams() |> Enum.sort_by(& &1.name) |> Enum.map(fn team -> {team.name, team.id} end)
  end

  defp admin_list_users() do
    Users.list_users()
    |> Enum.map(fn user -> {BordoWeb.Admin.UserView.full_name(user), user.id} end)
  end
end
