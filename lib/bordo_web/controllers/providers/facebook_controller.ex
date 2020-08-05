defmodule BordoWeb.Providers.FacebookController do
  use BordoWeb, :controller

  alias Bordo.Brands

  def auth(conn, %{"brand_id" => brand_id}) do
    conn
    |> redirect(external: get_auth_url(brand_id))
  end

  def reauth(conn, %{"brand_id" => brand_id}) do
    conn |> redirect(external: get_auth_url(brand_id, true))
  end

  @doc """
  Handles callback after following a redirect from an already connected channel.
  """
  def reauth_callback(conn, params) do
    %{"code" => _code, "state" => state} = params
    %{"brand_id" => brand_id} = URI.decode_query(state)
    brand = Brands.get_brand!(brand_id)

    conn
    |> put_flash(:success, "Reauthed!")
    |> redirect(to: Routes.live_path(conn, BordoWeb.SettingsLive, brand.slug))
  end

  defp get_auth_url(brand_id, reauth \\ false) do
    query =
      URI.encode_query(%{
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: redirect_location(reauth),
        state: URI.encode_query(%{brand_id: brand_id}),
        scope: "pages_manage_posts,pages_read_engagement"
      })

    %URI{
      host: "facebook.com",
      path: "/v6.0/dialog/oauth",
      port: 443,
      query: query,
      scheme: "https"
    }
    |> URI.to_string()
  end

  defp redirect_location(reauth) do
    if reauth do
      System.get_env("FACEBOOK_REAUTH_REDIRECT_URI")
    else
      System.get_env("FACEBOOK_REDIRECT_URI")
    end
  end
end
