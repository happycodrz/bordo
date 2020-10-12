defmodule BordoWeb.Plugs.WebhooksAuthPlugTest do
  use BordoWeb.ConnCase

  test "unauthorized without x-api-key" do
    conn =
      build_conn()
      |> bypass_through(BordoWeb.Router, [:webhooks])
      |> get("/providers/zapier/check")

    assert conn.status == 403
  end

  test "unauthorized without proper x-api-key" do
    conn =
      build_conn()
      |> put_req_header("x-api-key", "bad-key")
      |> bypass_through(BordoWeb.Router, [:webhooks])
      |> get("/providers/zapier/check")

    assert conn.status == 403
  end

  test "unauthorized with x-api-key" do
    channel = fixture(:channel, [], %{network: "zapier", token: "123"})

    conn =
      build_conn()
      |> put_req_header("x-api-key", "123")
      |> bypass_through(BordoWeb.Router, [:webhooks])
      |> get("/providers/zapier/check")

    assert conn.status == nil
  end
end
