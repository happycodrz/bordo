defmodule Bordo.Workers.HourlyChannelHealthCheck do
  use Oban.Worker

  alias Bordo.Channels
  alias Bordo.Channels.HealthCheck
  alias Bordo.Repo
  alias Slack.Web.Chat

  @impl Oban.Worker
  def perform(_job) do
    Channels.list_channels()
    |> Repo.preload(:brand)
    |> Enum.each(&check_channel(&1))

    :ok
  end

  def check_channel(channel) do
    case HealthCheck.check(channel) do
      :ok ->
        update_channel(:ok, channel)
        :ok

      {:error, :health_failure} ->
        update_channel(:error, channel)

        Chat.post_message(
          "feed-bordo-bot",
          format_message(channel)
        )

      _ ->
        :ok
    end
  end

  def format_message(channel) do
    """
    :bust_in_silhouette: *#{channel.brand.name}*
    :zap: *#{channel.network}* #{channel.id}
    :thumbsdown: Health check failed
    """
  end

  def update_channel(:ok, channel) do
    Channels.update_channel(channel, %{
      needs_reauthentication: false,
      health_last_checked_at: Timex.now()
    })
  end

  def update_channel(:error, channel) do
    Channels.update_channel(channel, %{
      needs_reauthentication: true,
      health_last_checked_at: Timex.now()
    })
  end
end

defmodule Bordo.Channels.HealthCheck do
  def check(%{network: "twitter"} = channel) do
    ExTwitter.configure(:process,
      consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
      consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
      access_token: channel.token,
      access_token_secret: channel.token_secret
    )

    ExTwitter.verify_credentials()

    :ok
  rescue
    ExTwitter.Error ->
      {:error, :health_failure}
  end

  def check(%{network: "facebook"} = channel) do
    case Facebook.me("id", channel.token) do
      {:ok, _} ->
        :ok

      _ ->
        {:error, :health_failure}
    end
  end

  def check(%{network: "linkedin"} = channel) do
    case Linkedin.me(channel.token) do
      {:ok, _} ->
        :ok

      _ ->
        {:error, :health_failure}
    end
  end

  def check(%{network: _}) do
    {:error, :unsupported_network}
  end
end
