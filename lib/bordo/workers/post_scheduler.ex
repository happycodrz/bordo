defmodule Bordo.Workers.PostScheduler do
  use Oban.Worker, queue: :events
  alias Bordo.Posts

  @impl Oban.Worker

  def perform(%Oban.Job{args: %{"post_id" => post_id}}) do
    post = Posts.get_scheduled_post!(post_id)
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
        "linkedin" => Bordo.Providers.Linkedin,
        "facebook" => Bordo.Providers.Facebook,
        "zapier" => Bordo.Providers.Zapier
      },
      network
    )
  end
end
