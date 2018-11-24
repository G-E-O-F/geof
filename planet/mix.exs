defmodule PLANET.MixProject do
  use Mix.Project

  def project do
    [
      name: "GEOF Planet",
      app: :geof_planet,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :gproc]
    ]
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
      {:gproc, "~> 0.8"},
      {:geof_shapes, path: "../shapes"}
    ]
  end
end
