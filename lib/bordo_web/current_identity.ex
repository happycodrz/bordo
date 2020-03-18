defmodule BordoWeb.CurrentIdentity do
  def current_identity(conn) do
    %Plug.Conn{
      assigns: %{current_identity: %Auth.Identity{team_id: team_id, user_id: user_id}}
    } = conn

    %{team_id: team_id}
  end
end
