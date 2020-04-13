defmodule BordoWeb.ProfileController do
  use BordoWeb, :controller

  alias Bordo.Users

  action_fallback BordoWeb.FallbackController

  def show(conn, _params) do
    user = Users.get_user!(user_id(conn))

    conn
    |> put_view(BordoWeb.UserView)
    |> render("show.json", user: user)
  end
end
