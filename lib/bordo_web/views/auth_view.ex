defmodule BordoWeb.AuthView do
  @moduledoc """
  Render Data Views for Auth result
  """
  use BordoWeb, :view

  def render("show.json", %{token_result: token_result}) do
    %{
      accessToken: token_result.access_token,
      expiresIn: token_result.expires_in
    }
  end
end
