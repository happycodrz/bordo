defmodule Bordo.Workers.PostScheduler do
  use Oban.Worker, queue: :events
  @impl Oban.Worker

  def perform(%{"post_id" => post_id}, _job) do
    post = Bordo.Posts.get_scheduled_post!(post_id)
    first_channel = post.post_variants |> Enum.at(0) |> Map.get(:channel)
    network_module = networks(first_channel.network)
    # TODO:
    # Map-apply private functions.
    # handle unknown network & have shared-validation for "networks"
    apply(network_module, :handle_event, [
      %{
        message: post.title,
        token: first_channel.token
      }
    ])

    :ok
  end

  def networks(network) do
    Map.get(
      %{
        "slack" => Bordo.Channels.SlackBot
      },
      network
    )
  end
end
