defmodule BordoWeb.CurrentIdentity do
  def current_identity(conn) do
    %Plug.Conn{
      assigns: %{current_identity: current_identity}
    } = conn

    current_identity
  end

  def user_id(conn) do
    %Auth.Identity{user_id: user_id} = conn |> current_identity()
    user_id
  end

  def team_id(conn) do
    %Auth.Identity{team_id: team_id} = conn |> current_identity()
    team_id
  end
end
