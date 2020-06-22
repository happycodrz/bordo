defmodule BordoWeb.Providers.FacebookController do
  use BordoWeb, :controller

  def auth(conn, %{"brand_id" => brand_id}) do
    conn
    |> redirect(external: get_auth_url(brand_id))
  end

  defp get_auth_url(brand_id) do
    query =
      URI.encode_query(%{
        client_id: System.get_env("FACEBOOK_APP_ID"),
        redirect_uri: System.get_env("FACEBOOK_REDIRECT_URI"),
        state: URI.encode_query(%{brand_id: brand_id})
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
end
