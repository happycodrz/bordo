defmodule BordoWeb.Webhooks.SubscriptionControllerTest do
  use BordoWeb.ConnCase

  alias Bordo.ChannelWebhooks

  test "lists posts from Bordo", %{conn: conn} do
    conn = conn |> get(Routes.subscription_path(conn, :index))

    assert json_response(conn, 200) == [
             %{
               "content" => "Post content from Bordo!",
               "media" => [
                 %{
                   "title" => "Image title",
                   "url" =>
                     "https://res.cloudinary.com/bordo/image/upload/v1601675411/lbrf8x0k172mi02916xy.jpg"
                 }
               ],
               "title" => "A title of the Bordo post"
             }
           ]
  end

  describe "create" do
    setup [:create_channel]

    test "creates a webhook", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-api-key", "123")
        |> post(Routes.subscription_path(conn, :create), %{
          "id" => 23_402_129,
          "hookUrl" => "http://zapier.com/webhooks/fake-webhook"
        })

      assert %{"status" => "Subscription created"} = json_response(conn, 201)
    end
  end

  describe "destroy" do
    setup [:create_channel, :create_webhook]

    test "destroys a webhook", %{conn: conn} do
      conn =
        conn
        |> put_req_header("x-api-key", "123")
        |> delete(Routes.subscription_path(conn, :delete, "456"))

      assert %{"status" => "Subscription removed"} = json_response(conn, 200)
    end
  end

  defp create_channel(_) do
    channel = fixture(:channel, [], %{network: "zapier", token: "123"})

    %{channel: channel}
  end

  defp create_webhook(%{channel: channel}) do
    {:ok, webhook} =
      ChannelWebhooks.create_channel_webhook(%{
        channel_id: channel.id,
        external_id: "456",
        webhook_url: "http://zapier.com/webhooks/fake-webhook"
      })

    %{webhook: webhook}
  end
end
