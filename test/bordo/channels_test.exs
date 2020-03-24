defmodule Bordo.ChannelsTest do
  use Bordo.DataCase

  alias Bordo.Channels

  describe "channels" do
    alias Bordo.Channels.Channel

    @valid_attrs %{auth_token: "some auth_token", network: "some network", refresh_token: "some refresh_token", uuid: "some uuid"}
    @update_attrs %{auth_token: "some updated auth_token", network: "some updated network", refresh_token: "some updated refresh_token", uuid: "some updated uuid"}
    @invalid_attrs %{auth_token: nil, network: nil, refresh_token: nil, uuid: nil}

    def channel_fixture(attrs \\ %{}) do
      {:ok, channel} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Channels.create_channel()

      channel
    end

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Channels.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Channels.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      assert {:ok, %Channel{} = channel} = Channels.create_channel(@valid_attrs)
      assert channel.auth_token == "some auth_token"
      assert channel.network == "some network"
      assert channel.refresh_token == "some refresh_token"
      assert channel.uuid == "some uuid"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Channels.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{} = channel} = Channels.update_channel(channel, @update_attrs)
      assert channel.auth_token == "some updated auth_token"
      assert channel.network == "some updated network"
      assert channel.refresh_token == "some updated refresh_token"
      assert channel.uuid == "some updated uuid"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Channels.update_channel(channel, @invalid_attrs)
      assert channel == Channels.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Channels.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Channels.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Channels.change_channel(channel)
    end
  end
end
