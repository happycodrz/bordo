defmodule Bordo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    config = Vapor.load!(Bordo.Config)

    # List all child processes to be supervised
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: Bordo.PubSub},
      # Start the Ecto repository
      Bordo.Repo,
      # Start telemetry for live dashboard
      Bordo.Telemetry,
      # Start the endpoint when the application starts
      {BordoWeb.Endpoint, port: config.web.port},
      {Oban, oban_config()}
      # Starts a worker by calling: Bordo.Worker.start_link(arg)
      # {Bordo.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bordo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BordoWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp oban_config do
    opts = Application.get_env(:bordo, Oban)

    # # Prevent running queues or scheduling jobs from an iex console.
    # if Code.ensure_loaded?(IEx) and IEx.started?() do
    #   opts
    #   |> Keyword.put(:crontab, false)
    #   |> Keyword.put(:queues, false)
    # else
    #   opts
    # end
    opts
  end
end
