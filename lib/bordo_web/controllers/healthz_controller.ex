defmodule BordoWeb.HealthzController do
  use BordoWeb, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "")
  end
end
