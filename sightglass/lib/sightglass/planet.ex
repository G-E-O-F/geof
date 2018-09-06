defmodule Sightglass.Planet do
  def get_planet(divisions) do
    mesh = PLANET.Geometry.Mesh.poly_per_field(divisions)

    %{
      id: divisions,
      divisions: divisions,
      mesh: %{
        position: mesh[:position],
        normal: mesh[:normal],
        index: mesh[:index]
      }
    }
  end
end
