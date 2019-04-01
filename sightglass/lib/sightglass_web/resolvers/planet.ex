defmodule GEOF.SightglassWeb.Resolvers.Planet do
  def create_planet(_parent, %{divisions: divisions}, _resolution) do
    {:ok, GEOF.Sightglass.Planet.create_planet(divisions)}
  end

  def get_planet_field_wireframe(_parent, %{id: sphere_id}, _resolution) do
    # todo: return :not_found if not found in cache, presumably
    {:ok, GEOF.Sightglass.Planet.get_planet_field_wireframe(sphere_id)}
  end

  def get_planet_field_mesh(_parent, %{id: sphere_id}, _resolution) do
    # todo: return :not_found if not found in cache, presumably
    {:ok, GEOF.Sightglass.Planet.get_planet_field_mesh(sphere_id)}
  end

  def compute_frame(_parent, %{id: sphere_id, iterator: fn_ref_fn}, _resolution) do
    # todo: return :not_found if not found in cache, presumably
    {:ok, GEOF.Sightglass.Planet.compute_frame(sphere_id, fn_ref_fn)}
  end
end
