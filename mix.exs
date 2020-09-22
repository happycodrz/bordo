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
      extra_applications: [:cloudex, :logger, :runtime_tools, :os_mon]
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
      {:appsignal, "~> 1.13.1"},
      {:auth0_ex, "~> 0.6"},
      {:cloudex, "~> 1.4",
       git: "https://github.com/ClementineOldfield/cloudex", branch: "master"},
      {:cors_plug, "~> 2.0"},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:ecto_autoslug_field, "~> 2.0"},
      {:ecto_sql, "~> 3.4"},
      {:extwitter, "~> 0.12.0"},
      {:facebook, "~> 0.24.0"},
      {:faker, "~> 0.13", only: :test},
      {:filtrex, "~> 0.4.3"},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.1.1"},
      {:httpoison, "~> 1.7.0"},
      {:jason, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:oauther, "~> 1.1"},
      {:oban, "~> 2.1.0"},
      {:phoenix, "~> 1.5.1"},
      {:phoenix_ecto, "~> 4.1"},
      {:phoenix_html, "2.14.2"},
      {:phoenix_live_view, "0.14.4", override: true},
      {:phoenix_live_dashboard, "~> 0.2.5"},
      {:phoenix_live_react, "~> 0.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:plug_cowboy, "~> 2.1"},
      {:postgrex, ">= 0.0.0"},
      {:slack, "~> 0.23.2"},
      {:stripity_stripe, "~> 2.0"},
      {:telemetry_metrics, "~> 0.4"},
      {:timex, "~> 3.6.1"}
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
