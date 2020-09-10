defmodule Bordo.Workers.PostSchedulerTest do
  use Bordo.DataCase
  use Oban.Testing, repo: Bordo.Repo

  # Setup a complete post
  setup do
    # default channel is twitter
    channel = fixture(:channel)
    post_variant = %{content: "content", channel_id: channel.id}
    post = fixture(:post, post_variants: [post_variant])
    {:ok, post: post}
  end

  # super happy-path just for a smoke test
  # still a useless test
  describe "#perform" do
    test "should create a tweet", %{post: post} do
      post = Bordo.Posts.get_post!(post.id)
      post_variant = Enum.at(post.post_variants, 0)
      assert post_variant.status == "scheduled"

      job =
        Bordo.Workers.PostScheduler.new(%{"post_id" => post.id})
        |> Oban.insert!()

      Bordo.Workers.PostScheduler.perform(job)

      post = Bordo.Posts.get_post!(post.id)
      post_variant = Enum.at(post.post_variants, 0)
      assert post_variant.status == "published"
    end
  end
end
