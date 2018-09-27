defmodule PLANET.MixProject do
  use Mix.Project

  def project do
    [
      app: :geof_planet,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :gproc]
    ]
  end

  defp deps do
    [
      {:gproc, "~> 0.8"},
      {:geof_shapes, path: "../shapes"}
    ]
  end
end
