defmodule Google do
  @moduledoc """
  Interact with the google api, used as a base resource for authentication.
  """

  @doc """
  Request the oauth2 url with options
  @state
  @scope https://www.googleapis.com/auth/business.manage
  """
  def auth_url(opts \\ []) do
    state = Access.get(opts, :state) || %{}
    scope = Access.get(opts, :scope) || ""

    query =
      URI.encode_query(%{
        client_id: System.get_env("GOOGLE_CLIENT_ID"),
        redirect_uri: System.get_env("GOOGLE_REDIRECT_URI"),
        response_type: "code",
        scope: scope,
        state: URI.encode_query(state)
      })

    %URI{
      host: "accounts.google.com",
      path: "/o/oauth2/auth",
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
        client_id: System.get_env("GOOGLE_CLIENT_ID"),
        client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
        redirect_uri: System.get_env("GOOGLE_REDIRECT_URI"),
        grant_type: "authorization_code"
      })

    %URI{
      host: "oauth2.googleapis.com",
      path: "/token",
      port: 443,
      query: query,
      scheme: "https"
    }
    |> URI.to_string()
    |> HTTPoison.post!("")
    |> Map.get(:body)
    |> Jason.decode!()
  end
end
