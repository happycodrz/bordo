defmodule Bordo.Providers.Twitter do
  def handle_event(%{channel: channel, message: message}) do
    create_tweet(channel, message)
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
