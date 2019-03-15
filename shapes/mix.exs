defmodule GEOF.Shapes.MixProject do
  use Mix.Project

  def project do
    [
      app: :geof_shapes,
      name: "Shapes",
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
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

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      # This option is only needed when you don't want to use the OTP application name
      # These are the default files included in the package
      files: ~w(lib test config .formatter.exs mix.exs README* LICENSE* ),
      licenses: ["BSD 3-Clause Clear License"],
      links: %{"GitHub" => "https://github.com/g-e-o-f/geof"}
    ]
  end

  defp description do
    """
      Shared utility functions for working with geometry.
    """
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10.5", only: :test, runtime: false},
      {:vector, "~> 1.0"}
    ]
  end
end
