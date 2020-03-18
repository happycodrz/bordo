defmodule BordoWeb.CurrentIdentity do
  def current_identity(conn), do: conn.assigns.current_identity
  def user_id(conn), do: current_identity(conn).user_id
  def team_id(conn), do: current_identity(conn).team_id
end
