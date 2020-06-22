defmodule BordoWeb.Providers.LinkedinController do
  use BordoWeb, :controller

  def auth(conn, %{"brand_id" => brand_id}) do
    auth_url = Linkedin.auth_url(state: %{brand_id: brand_id})

    redirect(conn, external: auth_url)
  end
end
