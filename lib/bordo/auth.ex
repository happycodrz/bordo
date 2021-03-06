defmodule Auth do
  @moduledoc """
  This module is responsible to authenticate client credentials against Auth0
  and provide access_token and expires_in as a result. This is for normal users, not admin.
  """
  alias Auth.{Credentials, TokenResult}
  alias Bordo.Users
  import Base
  require Logger

  @doc """
  Retrieves the access_token token for a username / password pair
  Returns {:ok, %TokenResult{access_token: 'ey...', expires_in: 86400}} or {:error, "reason"}
  ## Example:
      {:ok, result} = Auth.sign_in(%Credentials{username: "...", password: Base.encode64("...")})
  """
  @spec sign_in(Credentials.t()) :: {:ok, TokenResult.t()} | {:error, String.t()}
  def sign_in(%Credentials{username: username, password: encoded_password})
      when is_binary(username) and is_binary(encoded_password) do
    password = encoded_password |> decode64!(ignore: :whitespace)
    body = build_payload(username, password)
    headers = build_headers()

    %URI{
      host: config().host,
      port: 443,
      scheme: "https"
    }
    |> build_url()
    |> HTTPoison.post(body, headers)
    |> response
    |> parse
    |> find_or_create_user(username)
  end

  defp config do
    %{auth0: config} = Vapor.load!(Bordo.Config)
    config
  end

  defp build_url(%URI{} = url) do
    url |> Map.put(:path, "/oauth/token") |> URI.to_string()
  end

  defp build_headers, do: ["Content-type": "application/json"]

  defp build_payload(username, password) do
    %{
      grant_type: "password",
      username: username,
      password: password,
      audience: config().audience,
      scope: "read:all",
      client_id: config().client_id,
      client_secret: config().client_secret
    }
    # This is a predictable step, it cannot fail, error handling omitted intentionally
    |> Jason.encode!()
  end

  defp response({:ok, %{status_code: 200, body: body}}), do: {:ok, body}
  defp response({:ok, %{status_code: 401}}), do: {:error, :unauthorized}
  defp response({:ok, %{status_code: 403}}), do: {:error, :forbidden}

  defp response({:ok, %{status_code: status_code}}),
    do: {:error, "HTTP Status #{status_code} received"}

  defp response({:error, %{reason: reason}}), do: {:error, reason}

  defp parse({:ok, body}) do
    result =
      body
      |> Jason.decode!(keys: :atoms)
      |> Map.take([:access_token, :expires_in])

    {:ok, struct(TokenResult, result)}
  end

  defp parse({:error, :unauthorised}), do: {:error, :unauthorized}
  defp parse({:error, :forbidden}), do: {:error, :forbidden}

  defp parse({:error, error}) do
    _ = Logger.warn(fn -> "Failed to authenticate due to #{inspect(error)}" end)
    {:error, :unauthorized}
  end

  defp find_or_create_user(
         {:ok, %Auth.TokenResult{access_token: access_token} = token_result},
         email
       ) do
    with {:ok, %{"sub" => "auth0|" <> id}} <- Auth.Guardian.decode_and_verify(access_token),
         {:ok, user} <- Users.find_or_create(%{email: email, auth0_id: id}) do
      {:ok, token_result, user}
    else
      error ->
        {:error, error}
    end
  end

  defp find_or_create_user({:error, _}, _), do: {:error, :forbidden}
end
