defmodule Bordo.Channels.SlackBot do
  @moduledoc """
  A channel for testing and a starting point for building adapters/integrations
  """
  def handle_event(%{"message" => message, "token" => token}) do
    Slack.Web.Chat.post_message("dev-testing", message, %{token: token})
  end
end
