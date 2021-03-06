defmodule Bordo.Providers.Twitter do
  require Logger

  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant
  alias ExTwitter.Model.Tweet

  def handle_event(%PostVariant{status: "published"} = post_variant), do: {:ok, post_variant}

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    case create_tweet(channel, content, media) do
      %Tweet{id: id} ->
        string_id = Integer.to_string(id)

        post_variant
        |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})

      _error ->
        post_variant |> PostVariants.update_post_variant(%{status: "failed"})
    end
  end

  def create_tweet(channel, status, media) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: channel.token,
      access_token_secret: channel.token_secret
    )

    if Application.get_env(:bordo, :twitter_live) do
      if length(media) > 0 do
        media = Enum.at(media, 0)
        file_name = media.url |> String.split("/") |> Enum.at(-1)
        %HTTPoison.Response{body: body} = HTTPoison.get!(media.url)
        File.write!("/tmp/" <> file_name, body)

        image = File.read!("/tmp/" <> file_name)
        ExTwitter.update_with_media(status, image)
      else
        ExTwitter.update(status)
      end
    else
      Logger.info("TWEET CREATED")
      %Tweet{id: Enum.random(0..1000)}
    end
  end

  def destroy_tweet(tweet_id) do
    ExTwitter.destroy_status(tweet_id)
  end
end
