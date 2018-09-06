defmodule SightglassWeb.Resolvers.Planet do
  def get_planet(_parent, %{divisions: divisions}, _resolution) do
    {:ok, Sightglass.Planet.get_planet(divisions)}
  end
end
