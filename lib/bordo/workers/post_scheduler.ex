defmodule Bordo.Workers.PostScheduler do
  use Oban.Worker, queue: :events

  @impl Oban.Worker
  def perform(%{"post_id" => _id} = args, _job) do
    IO.puts("RUNNING POST SCHEDULER")
    # find post + post_variant
    # dispatch service/adapter
    # handle failure?
    case args do
      _ ->
        IO.inspect(args)
    end

    :ok
  end
end
