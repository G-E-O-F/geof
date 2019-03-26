defmodule GEOF.Sightglass.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geof_sightglass,
      version: "0.0.1",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: test(),
      preferred_cli_env: cli_env()
    ]
  end

  def test do
    [
      tool: ExCoveralls,
      output: "_cover"
    ]
  end

  def cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {GEOF.Sightglass.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:absinthe_phoenix, "~> 1.4"},
      {:cowboy, "~> 1.0"},
      {:distillery, "~> 2.0"},
      {:excoveralls, "~> 0.10.5", only: :test, runtime: false},
      {:geof_planet, [path: "../planet"]},
      {:gettext, "~> 0.11"},
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:uuid, "~> 1.1"}
    ]
  end
end
