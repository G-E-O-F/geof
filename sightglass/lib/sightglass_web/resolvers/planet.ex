defmodule GEOF.SightglassWeb.Resolvers.Planet do
  def create_planet(_parent, %{divisions: divisions}, _resolution) do
    {:ok, GEOF.Sightglass.Planet.create_planet(divisions)}
  end

  def get_planet_wireframe(_parent, %{id: sphere_id}, _resolution) do
    # todo: return :not_found if not found in cache, presumably
    {:ok, GEOF.Sightglass.Planet.get_planet_wireframe(sphere_id)}
  end

  def get_planet_mesh(_parent, %{id: sphere_id}, _resolution) do
    # todo: return :not_found if not found in cache, presumably
    {:ok, GEOF.Sightglass.Planet.get_planet_mesh(sphere_id)}
  end
end
