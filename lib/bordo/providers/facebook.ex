defmodule Bordo.Providers.Facebook do
  require Logger
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    case create_post(channel, content, media) do
      {:ok, post} ->
        string_id = post["id"]

        post_variant
        |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})

      _error ->
        post_variant |> PostVariants.update_post_variant(%{status: "failed"})
    end
  end

  def create_post(channel, content, media) do
    if Application.get_env(:bordo, :facebook_live) do
      {:ok, page_info} = Facebook.page(channel.resource_id, channel.token, ["access_token"])

      if length(media) > 0 do
        media = Enum.at(media, 0)
        file_name = media.url |> String.split("/") |> Enum.at(-1)
        %HTTPoison.Response{body: body} = HTTPoison.get!(media.url)
        File.write!("/tmp/" <> file_name, body)

        Facebook.publish(
          :photo,
          channel.resource_id,
          "/tmp/" <> file_name,
          [message: content],
          page_info["access_token"]
        )
      else
        Facebook.publish(
          :feed,
          channel.resource_id,
          [message: content],
          page_info["access_token"]
        )
      end
    else
      Logger.info("FACEBOOK POST CREATED")
    end
  end
end
