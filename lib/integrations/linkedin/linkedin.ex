defmodule Linkedin do
  use HTTPoison.Base
  alias Bordo.ContentParser

  @endpoint "https://api.linkedin.com/"

  def me(token) do
    case get("v2/me", [
           {"Authorization", "Bearer #{token}"}
         ]) do
      {:ok, %HTTPoison.Response{body: {:ok, body}}} -> {:ok, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end

  def auth_url(opts \\ []) do
    state = Access.get(opts, :state) || %{}

    query =
      URI.encode_query(%{
        state: URI.encode_query(state),
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: System.get_env("LINKEDIN_REDIRECT_URI"),
        response_type: "code",
        scope: "w_member_social,w_organization_social,r_liteprofile,rw_organization_admin"
      })

    %URI{
      host: "www.linkedin.com",
      path: "/oauth/v2/authorization",
      port: 443,
      query: query,
      scheme: "https"
    }
    |> URI.to_string()
  end

  def access_token(code) do
    query =
      URI.encode_query(%{
        code: code,
        client_id: System.get_env("LINKEDIN_CLIENT_ID"),
        redirect_uri: System.get_env("LINKEDIN_REDIRECT_URI"),
        client_secret: System.get_env("LINKEDIN_CLIENT_SECRET"),
        grant_type: "authorization_code"
      })

    uri = %URI{
      host: "www.linkedin.com",
      path: "/oauth/v2/accessToken",
      port: 443,
      query: query,
      scheme: "https"
    }

    with {:ok, response} <- get_token(uri) do
      response
      |> Map.get(:body)
      |> Jason.decode()
    end
  end

  def list_companies(token) do
    HTTPoison.get!("https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode()
  end

  def get_organization(token, org_id) do
    HTTPoison.get!(
      "https://api.linkedin.com/v2/organizations/#{org_id}",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end

  def get_profile_image(token, org_id) do
    HTTPoison.get!(
      "https://api.linkedin.com/v2/organizations/#{org_id}?projection=(coverPhotoV2(original~:playableStreams,cropped~:playableStreams,cropInfo),logoV2(original~:playableStreams,cropped~:playableStreams,cropInfo))",
      Authorization: "Bearer #{token}"
    )
    |> Map.get(:body)
    |> Jason.decode!()
  end

  @doc """
  Create a text-only share
  """
  def share(token, owner, content) do
    {:ok, body} = build_share_body(owner, content)

    HTTPoison.post!(
      "https://api.linkedin.com/v2/shares",
      body,
      [{"X-Restli-Protocol-Version", "2.0.0"}, {"Authorization", "Bearer #{token}"}]
    )
    |> Map.get(:body)
    |> Jason.decode()
  end

  @doc """
  Create a media share
  """
  def share(token, owner, content, media) do
    li_asset = upload_media(token, owner, media)
    {:ok, body} = build_share_body(owner, content, li_asset)

    HTTPoison.post!(
      "https://api.linkedin.com/v2/shares",
      body,
      [
        {"X-Restli-Protocol-Version", "2.0.0"},
        {"Authorization", "Bearer #{token}"}
      ]
    )
    |> Map.get(:body)
    |> Jason.decode()
  end

  @doc """
  Upload media

  iex> Linkedin.upload_media("<Access Token>", "<Owner Urn>", "%Media{}")
  "urn:li:digitalmediaAsset:C4E22AQH-jrNeFvFiYg"
  """
  def upload_media(token, owner, media) do
    file_name = media.url |> String.split("/") |> Enum.at(-1)
    %HTTPoison.Response{body: body} = HTTPoison.get!(media.url)
    File.write!("/tmp/" <> file_name, body)
    image = File.read!("/tmp/" <> file_name)

    {:ok,
     %{
       "value" => %{
         "asset" => li_asset,
         "uploadMechanism" => %{
           "com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest" => %{
             "uploadUrl" => upload_url
           }
         }
       }
     }} = request_upload(token, owner)

    resp =
      HTTPoison.post(
        upload_url,
        image,
        [{"X-Restli-Protocol-Version", "2.0.0"}, {"Authorization", "Bearer #{token}"}],
        recv_timeout: 30_000
      )

    case resp do
      {:ok, _body} ->
        li_asset

      error ->
        error
    end
  end

  defp get_token(uri) do
    uri |> URI.to_string() |> HTTPoison.post("", [{"Content-Type", "x-www-form-urlencoded"}])
  end

  def process_response_body(body), do: Jason.decode(body)

  def process_url(url) do
    @endpoint <> url
  end

  def request_upload(token, owner) do
    {:ok, body} =
      Jason.encode(%{
        registerUploadRequest: %{
          owner: owner,
          recipes: [
            "urn:li:digitalmediaRecipe:feedshare-image"
          ],
          serviceRelationships: [
            %{
              identifier: "urn:li:userGeneratedContent",
              relationshipType: "OWNER"
            }
          ]
        }
      })

    HTTPoison.post!("https://api.linkedin.com/v2/assets?action=registerUpload", body, [
      {"X-Restli-Protocol-Version", "2.0.0"},
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ])
    |> Map.get(:body)
    |> Jason.decode()
  end

  defp build_share_body(urn, content) do
    parsed_content = ContentParser.parse(:linkedin, content)

    if Enum.empty?(parsed_content[:links]) do
      Jason.encode(%{
        "distribution" => %{
          "linkedInDistributionTarget" => %{}
        },
        "owner" => urn,
        "subject" => content,
        "text" => %{
          "text" => content
        }
      })
    else
      Jason.encode(%{
        "distribution" => %{
          "linkedInDistributionTarget" => %{}
        },
        "content" => %{
          "contentEntities" => [
            %{
              "entityLocation" => parsed_content[:links] |> List.first()
            }
          ]
        },
        "owner" => urn,
        "subject" => parsed_content[:message],
        "text" => %{
          "text" => parsed_content[:message]
        }
      })
    end
  end

  defp build_share_body(urn, content, li_asset) do
    Jason.encode(%{
      "content" => %{
        "contentEntities" => [
          %{
            "entity" => li_asset
          }
        ],
        "description" => "content description",
        "title" => "Test Share with Content",
        "shareMediaCategory" => "IMAGE"
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
