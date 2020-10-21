defmodule Bordo.Providers.Zapier do
  require Logger

  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{status: "published"} = post_variant), do: {:ok, post_variant}

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    case push_webhooks(channel, content, media) do
      {:ok, id} ->
        post_variant
        |> PostVariants.update_post_variant(%{external_id: id, status: "published"})

      _error ->
        post_variant |> PostVariants.update_post_variant(%{status: "failed"})
    end
  end

  def push_webhooks(channel, content, media) do
    if Application.get_env(:bordo, :zapier_live) do
      Enum.each(channel.webhooks, fn webhook ->
        HTTPoison.post!(webhook.webhook_url, build_body(content, media))
        |> Map.get(:body)
        |> Jason.decode!()
      end)

      # Since zapier has many webhooks, we can't store a single id. For now, we'll just ignore it
      {:ok, "temp-zap-id"}
    else
      Logger.info("ZAP PUSHED")
      {:ok, Enum.random(0..1000)}
    end
  end

  defp build_body(content, media) do
    Jason.encode!(%{
      content: content,
      media:
        Enum.map(media, fn media ->
          %{
            title: media.title,
            url: media.url
          }
        end)
    })
  end
end
