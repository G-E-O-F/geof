defmodule GEOF.Shapes.MixProject do
  use Mix.Project

  def project do
    [
      app: :geof_shapes,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:vector, "~> 1.0"}
    ]
  end
end
