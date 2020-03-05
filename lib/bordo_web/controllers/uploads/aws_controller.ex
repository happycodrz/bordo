defmodule BordoWeb.Uploads.AwsController do
  use BordoWeb, :controller

  action_fallback BordoWeb.FallbackController

  @aws_bucket Application.get_env(:bordo, :aws)[:bucket_name]

  def create(conn, %{"file" => file_params}) do
    with {:ok, url} <- presign_url(file_params["file_name"]) do
      conn
      |> put_status(:created)
      |> json(%{url: url})
    end
  end

  defp presign_url(file_name) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, @aws_bucket, file_name)
  end
end
