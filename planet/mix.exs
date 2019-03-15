defmodule PLANET.MixProject do
  use Mix.Project

  def project do
    [
      name: "Planet",
      app: :geof_planet,
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

  def application do
    [
      extra_applications: [:logger, :gproc]
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
      A configurable spherical geodesic grid data model designed for simulations
      GEOF Planet offers an ideal data model for simulations of 2½D spherical phenomena like oceanography and climate. It is ported from the JavaScript project g-e-o-f/peels.
    """
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      groups_for_modules: [
        Ontology: [
          GEOF.Planet.Sphere,
          GEOF.Planet.Field
        ],
        Geometry: [
          GEOF.Planet.Geometry,
          GEOF.Planet.Geometry.FieldCentroids,
          GEOF.Planet.Geometry.InterfieldCentroids,
          GEOF.Planet.Geometry.Mesh,
          GEOF.Planet.Pattern
        ],
        Servers: [
          GEOF.Planet.SphereServer,
          GEOF.Planet.PanelSupervisor,
          GEOF.Planet.PanelServer,
          GEOF.Planet.Registry
        ]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10.5", only: :test, runtime: false},
      {:gproc, "~> 0.8"},
      {:geof_shapes, "~> 0.1.0"}
    ]
  end
end
