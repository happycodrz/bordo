defmodule Linkedin do
  use HTTPoison.Base

  @endpoint "https://api.linkedin.com/"

  def me(token) do
    case get("v2/me", [
           {"Authorization", "Bearer #{token}"}
         ]) do
      {:ok, %HTTPoison.Response{body: {:ok, body}}} -> {:ok, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end

  def auth_url(opts \\ []) do
    state = Access.get(opts, :state) || %{}

    query =
      URI.encode_query(%{
        state: URI.encode_query(state),
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: System.get_env("LINKEDIN_REDIRECT_URI"),
        response_type: "code",
        scope: "w_member_social,w_organization_social,r_liteprofile,rw_organization_admin"
      })

    %URI{
      host: "www.linkedin.com",
      path: "/oauth/v2/authorization",
      port: 443,
      query: query,
      scheme: "https"
    }
    |> URI.to_string()
  end

  def access_token(code) do
    query =
      URI.encode_query(%{
        code: code,
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: System.get_env("LINKEDIN_REDIRECT_URI"),
        client_secret: System.get_env("LINKEDIN_CLIENT_SECRET"),
        grant_type: "authorization_code"
      })

    uri = %URI{
      host: "www.linkedin.com",
      path: "/oauth/v2/accessToken",
      port: 443,
      query: query,
      scheme: "https"
    }

    with {:ok, response} <- get_token(uri) do
      response
      |> Map.get(:body)
      |> Jason.decode()
    end
  end

  def list_companies(token) do
    HTTPoison.get!("https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode()
  end

  def get_organization(token, org_id) do
    HTTPoison.get!(
      "https://api.linkedin.com/v2/organizations/#{org_id}?projection=(logoV2(original~:playableStreams))",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end

  def get_profile_image(token, org_id) do
    HTTPoison.get!(
      "https://api.linkedin.com/v2/organizations/#{org_id}?projection=(coverPhotoV2(original~:playableStreams,cropped~:playableStreams,cropInfo),logoV2(original~:playableStreams,cropped~:playableStreams,cropInfo))",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end

  defp get_token(uri) do
    uri |> URI.to_string() |> HTTPoison.post("", [{"Content-Type", "x-www-form-urlencoded"}])
  end

  def process_response_body(body), do: Jason.decode(body)

  def process_url(url) do
    @endpoint <> url
  end
end
