defmodule Bordo.Workers.PostScheduler do
  use Oban.Worker, queue: :events
  @impl Oban.Worker

  def perform(%{"post_id" => post_id}, _job) do
    post = Bordo.Posts.get_scheduled_post!(post_id)
    post.post_variants |> Enum.each(&dispatch_post_variant(&1))
  end

  defp dispatch_post_variant(post_variant) do
    networks(post_variant.channel.network)
    |> apply(
      :handle_event,
      [post_variant]
    )
  end

  defp networks(network) do
    Map.get(
      %{
        "slack" => Bordo.Channels.SlackBot,
        "twitter" => Bordo.Providers.Twitter,
        "linkedin" => Bordo.Providers.Linkedin
      },
      network
    )
  end
end
