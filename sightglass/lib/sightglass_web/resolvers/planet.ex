defmodule GEOF.SightglassWeb.Resolvers.Planet do
  def get_planet(_parent, %{divisions: divisions}, _resolution) do
    {:ok, GEOF.Sightglass.Planet.get_planet(divisions)}
  end

  def get_planet_edges(_parent, %{divisions: divisions}, _resolution) do
    {:ok, GEOF.Sightglass.Planet.get_planet_edges(divisions)}
  end

  def get_planet_frame(_parent, %{divisions: divisions, pattern: pattern}, _resolution) do
    {:ok, GEOF.Sightglass.Planet.get_planet_frame(divisions, pattern)}
  end
end
