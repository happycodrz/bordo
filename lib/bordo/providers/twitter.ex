defmodule Bordo.Providers.Twitter do
  alias ExTwitter.Model.Tweet
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{channel: channel, content: content} = post_variant) do
    with %Tweet{id: id} <- create_tweet(channel, content) do
      string_id = Integer.to_string(id)

      post_variant
      |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})
    else
      _error ->
        post_variant |> PostVariants.update_post_variant(%{status: "failed"})
    end
  end

  def create_tweet(channel, status) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: channel.token,
      access_token_secret: channel.token_secret
    )

    ExTwitter.update(status)
  end

  def destroy_tweet(tweet_id) do
    ExTwitter.destroy_status(tweet_id)
  end
end
