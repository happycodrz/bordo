defmodule Bordo.Providers.Linkedin do
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{channel: channel, content: content} = post_variant) do
    urn = get_profile(channel) |> get_profile_urn()

    with {:ok, post} <- create_share(channel, content, urn) do
      string_id = post["id"]

      post_variant
      |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})
    else
      _error ->
        post_variant
        |> PostVariants.update_post_variant(%{status: "published"})
    end
  end

  defp create_share(channel, content, urn) do
    {:ok, body} =
      Jason.encode(%{
        "author" => urn,
        "lifecycleState" => "PUBLISHED",
        "specificContent" => %{
          "com.linkedin.ugc.ShareContent" => %{
            "shareCommentary" => %{
              "text" => content
            },
            "shareMediaCategory" => "NONE"
          }
        },
        "visibility" => %{
          "com.linkedin.ugc.MemberNetworkVisibility" => "PUBLIC"
        }
      })

    HTTPoison.post!(
      "https://api.linkedin.com/v2/ugcPosts",
      body,
      [{"X-Restli-Protocol-Version", "2.0.0"}, {"Authorization", "Bearer #{channel.token}"}]
    )
    |> Map.get(:body)
    |> Jason.decode()
    |> IO.inspect()
  end

  defp get_profile(%{token: token}) do
    HTTPoison.get!("https://api.linkedin.com/v2/me", [
      {"Authorization", "Bearer #{token}"}
    ])
    |> Map.get(:body)
    |> Jason.decode()
  end

  defp get_profile_urn({:ok, profile}) do
    %{"id" => id} = profile
    "urn:li:person:#{id}"
  end
end
