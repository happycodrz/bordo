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

  def process_response_body(body), do: Jason.decode(body)

  def process_url(url) do
    @endpoint <> url
  end
end
