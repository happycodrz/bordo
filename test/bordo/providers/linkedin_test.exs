defmodule Bordo.Providers.LinkedinTest do
  use Bordo.DataCase

  alias Bordo.PostVariants
  alias Bordo.Providers.Linkedin
  alias Bordo.Repo

  describe "#handle_event/1" do
    test "it creates a tweet when scheduled" do
      channel = fixture(:channel, network: "linkedin")

      post_variant =
        PostVariants.get_post_variant!(
          fixture(:post_variant, %{channel: channel}, %{status: "scheduled"}).id
        )
        |> Repo.preload(:channel)

      assert post_variant.status == "scheduled"
      {:ok, updated_post_variant} = Linkedin.handle_event(post_variant)
      assert updated_post_variant.status == "published"
    end

    test "it does not resend a tweet when published" do
      channel = fixture(:channel, network: "linkedin")

      post_variant =
        PostVariants.get_post_variant!(
          fixture(:post_variant, %{channel: channel}, %{status: "published"}).id
        )
        |> Repo.preload(:channel)

      external_id = post_variant.external_id
      {:ok, updated_post_variant} = Linkedin.handle_event(post_variant)
      assert external_id == updated_post_variant.external_id
    end
  end
end
