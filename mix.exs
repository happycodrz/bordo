defmodule Bordo.MixProject do
  use Mix.Project

  def project do
    [
      app: :bordo,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Bordo.Application, []},
      extra_applications: [:cloudex, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:appsignal, "~> 1.0"},
      {:cloudex, "~> 1.4"},
      {:cors_plug, "~> 2.0"},
      {:credo, "~> 1.3.2", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.4"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:extwitter, "~> 0.12.0"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.1.1"},
      {:httpoison, "~> 1.6.2"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:oban, "~> 1.2.0"},
      {:phoenix, "~> 1.4.12"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_pubsub, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.6.1"},
      {:slack, "~> 0.22.0"},
      {:sweet_xml, "~> 0.6.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
