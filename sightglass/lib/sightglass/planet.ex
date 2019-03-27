defmodule GEOF.Sightglass.Planet do
  alias GEOF.Sightglass.PlanetCache.Cache

  def create_planet(divisions) do
    sphere_id = Cache.start_planet(divisions: divisions)

    %{
      id: sphere_id,
      divisions: divisions
    }
  end

  def get_planet_mesh(sphere_id) do
    %{:divisions => div, :field_centroids => f_c, :interfield_centroids => if_c} =
      Cache.get_planet_basic_geometry(sphere_id)

    mesh = GEOF.Planet.Geometry.Mesh.poly_per_field(div, f_c, if_c)

    %{
      id: sphere_id,
      divisions: div,
      mesh: %{
        position: mesh[:position],
        normal: mesh[:normal],
        index: mesh[:index],
        vertex_order: mesh[:vertex_order]
      }
    }
  end

  def get_planet_wireframe(sphere_id) do
    %{:divisions => div, :field_centroids => f_c, :interfield_centroids => if_c} =
      Cache.get_planet_basic_geometry(sphere_id)

    edge_mesh = GEOF.Planet.Geometry.EdgeMesh.poly_per_field(div, f_c, if_c)

    %{
      id: sphere_id,
      divisions: div,
      wireframe: %{
        position: edge_mesh[:position],
        index: edge_mesh[:index]
      }
    }
  end
end
