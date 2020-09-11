defmodule Bordo.Providers.Linkedin do
  alias Linkedin
  require Logger
  alias Bordo.PostVariants
  alias Bordo.PostVariants.PostVariant

  def handle_event(%PostVariant{status: "published"} = post_variant), do: {:ok, post_variant}

  def handle_event(%PostVariant{channel: channel, content: content, media: media} = post_variant) do
    case create_share(channel, content, media) do
      {:ok, post} ->
        string_id = post["id"]

        post_variant
        |> PostVariants.update_post_variant(%{external_id: string_id, status: "published"})

      _error ->
        post_variant
        |> PostVariants.update_post_variant(%{status: "published"})
    end
  end

  def create_share(channel, content, media) do
    if Application.get_env(:bordo, :linkedin_live) do
      owner = "urn:li:organization:" <> channel.resource_id

      if Enum.any?(media) do
        media = Enum.at(media, 0)
        Linkedin.share(channel.token, owner, content, media)
      else
        Linkedin.share(channel.token, owner, content)
      end
    else
      Logger.info("LINKEDIN SHARE CREATED")
      {:ok, %{"id" => Integer.to_string(Enum.random(0..1000))}}
    end
  end
end
