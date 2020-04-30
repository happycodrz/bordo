defmodule Bordo.Providers.Facebook do
  require Logger
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    with {:ok, post} <- create_post(channel, content, media) do
      string_id = post["id"]

      post_variant
      |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})
    else
      _error ->
        post_variant |> PostVariants.update_post_variant(%{status: "failed"})
    end
  end

  def create_post(channel, content, media) do
    if Mix.env() == :prod do
      {:ok, page_info} = Facebook.page(channel.resource_id, channel.token, ["access_token"])

      Facebook.publish(
        :feed,
        channel.resource_id,
        [message: content],
        page_info["access_token"]
      )
    else
      Logger.info("FACEBOOK POST CREATED")
    end
  end
end
