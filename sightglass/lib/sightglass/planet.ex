defmodule GEOF.Sightglass.Planet.Battery do
  def add_one_to_field({_field_index, field_data}, _adjacent_fields_with_data, _sphere_data) do
    if field_data == nil do
      1
    else
      field_data + 1
    end
  end
end

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

    mesh = GEOF.Planet.Geometry.FieldMesh.field_mesh(div, f_c, if_c)

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
    %{:divisions => div, :field_edges => f_e, :interfield_centroids => if_c} =
      Cache.get_planet_basic_geometry(sphere_id)

    edge_mesh = GEOF.Planet.Geometry.FieldEdgeMesh.field_edge_mesh(if_c, f_e)

    %{
      id: sphere_id,
      divisions: div,
      wireframe: %{
        position: edge_mesh[:position],
        index: edge_mesh[:index]
      }
    }
  end

  def compute_frame(sphere_id, _fn_ref_fn) do
    divisions = Cache.get_planet_divisions(sphere_id)
    Cache.compute_frame(sphere_id, self(), {"GEOF.Sightglass.Planet.Battery", "add_one_to_field"})

    frame_colors =
      receive do
        {:frame_complete, fields_data} ->
          Enum.reduce(fields_data, %{}, fn {field_index, field_data}, frame ->
            Map.put(
              frame,
              GEOF.Planet.Field.flatten_index(field_index, divisions),
              GEOF.Planet.Patterns.int_to_color(field_data)
            )
          end)

        error ->
          IO.puts('[error on receive]')
          IO.inspect(error)
          error
      end

    %{
      id: sphere_id,
      colors: frame_colors
    }
  end
end
