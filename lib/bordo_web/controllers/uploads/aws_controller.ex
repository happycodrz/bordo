defmodule BordoWeb.Uploads.AwsController do
  use BordoWeb, :controller

  action_fallback BordoWeb.FallbackController

  @aws_bucket Application.get_env(:bordo, :aws)[:bucket_name]

  def create(conn, %{"file" => %{"file_name" => file_name}}) do
    file_ext = file_name |> String.split(".") |> Enum.at(-1)
    file_name = Bordo.Schema.generate_short_uuid()
    file_path = "tmp/" <> file_name <> "." <> file_ext

    with {:ok, url} <- presign_url(file_path) do
      conn
      |> put_status(:created)
      |> json(%{url: url})
    end
  end

  defp presign_url(file_name) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:put, @aws_bucket, file_name)
  end
end
