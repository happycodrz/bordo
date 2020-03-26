defmodule Bordo.Workers.PostScheduler do
  use GenServer

  alias Bordo.Posts

  @schedule_interval 10_000

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(state) do
    schedule_posts()
    {:ok, state}
  end

  def handle_info(:schedule_posts, state) do
    IO.inspect("Getting posts that need to be scheduled this minuteP")
    schedule_posts()
    IO.inspect(posts_that_need_to_run())
    {:noreply, state}
  end

  defp schedule_posts do
    Process.send_after(self(), :schedule_posts, @schedule_interval)
  end

  defp posts_that_need_to_run() do
    Posts.list_posts_to_schedule()
  end

  def schedule_interval(), do: @schedule_interval
end
