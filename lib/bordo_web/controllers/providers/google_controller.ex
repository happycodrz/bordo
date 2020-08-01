defmodule BordoWeb.Providers.GoogleController do
  use BordoWeb, :controller

  alias Bordo.Brands
  alias Bordo.Channels
  alias Bordo.Channels.Channel

  def auth(conn, %{"brand_id" => brand_id}) do
    conn
    |> redirect(
      external:
        Google.auth_url(
          scope: "https://www.googleapis.com/auth/business.manage",
          state: %{brand_id: brand_id}
        )
    )
  end

  def callback(conn, %{
        "code" => code,
        "state" => "brand_id=" <> brand_id
      }) do
    brand = Brands.get_brand!(brand_id)

    %{"access_token" => access_token} = Google.access_token(code)
    Channels.create_channel(build_channel_params(access_token, brand_id))

    conn |> redirect(to: Routes.live_path(conn, BordoWeb.SettingsLive, brand.slug))
  end

  defp build_channel_params(access_token, brand_id) do
    %{
      "token" => access_token,
      "network" => "google",
      "brand_id" => brand_id
    }
  end
end
