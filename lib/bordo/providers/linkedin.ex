defmodule Bordo.Providers.Linkedin do
  alias Linkedin
  require Logger
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    {:ok, %{"id" => id}} = Linkedin.me(channel.token)
    urn = "urn:li:person:" <> id

    case create_share(channel, content, media, urn) do
      {:ok, post} ->
        string_id = post["id"]

        post_variant
        |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})

      _error ->
        post_variant
        |> PostVariants.update_post_variant(%{status: "published"})
    end
  end

  defp create_share(channel, content, media, urn) do
    {:ok, body} = build_body(content, media, urn)

    if Application.get_env(:bordo, :linkedin_live) do
      HTTPoison.post!(
        "https://api.linkedin.com/v2/shares",
        body,
        [{"X-Restli-Protocol-Version", "2.0.0"}, {"Authorization", "Bearer #{channel.token}"}]
      )
      |> Map.get(:body)
      |> Jason.decode()
    else
      Logger.info("LINKEDIN SHARE CREATED")
    end
  end

  defp build_body(content, media, urn) do
    Jason.encode(%{
      "content" => %{
        "contentEntities" =>
          Enum.map(media, fn media ->
            %{
              "entityLocation" => media.url,
              "thumbnails" => [
                %{
                  "resolvedUrl" => media.url
                }
              ]
            }
          end)
      },
      "distribution" => %{
        "linkedInDistributionTarget" => %{}
      },
      "owner" => urn,
      "subject" => content,
      "text" => %{
        "text" => content
      }
    })
  end
end
