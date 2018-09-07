defmodule GEOF.Planet.Geometry.InterfieldCentroids do
  import GEOF.Planet.Geometry
  import GEOF.Planet.Sphere
  import GEOF.Planet.Field

  @moduledoc """
    Functions for computing the positions of the centroids between each
    Field on a Sphere. This is used to determine the vertices of a
    field's bounding polygon.
  """

  ###
  #
  # TYPES
  #
  ###

  @type interfield_triangle_index :: MapSet.t(GEOF.Planet.Field.index())
  @type interfield_centroid_sphere :: %{
          interfield_triangle_index => GEOF.Planet.Geometry.position()
        }

  ###
  #
  # FUNCTIONS
  #
  ###

  # Note: `divisions` is abbreviated as `d` in private functions.

  ##
  # Utility functions
  ##

  @spec set_position(
          interfield_centroid_sphere,
          list(GEOF.Planet.Field.index()),
          GEOF.Planet.Geometry.position()
        ) :: interfield_centroid_sphere

  defp set_position(sphere, [index1, index2, index3], {:pos, lat, lon}) do
    Map.put(sphere, MapSet.new([index1, index2, index3]), {:pos, lat, lon})
  end

  ##
  #
  # Centroid sphere computation
  #
  ##

  # Convenience function without need for a `centroid_sphere`

  @spec interfield_centroids(integer) :: interfield_centroid_sphere

  def interfield_centroids(divisions) when is_integer(divisions) and divisions > 0 do
    interfield_centroids(
      GEOF.Planet.Geometry.FieldCentroids.field_centroids(divisions),
      divisions
    )
  end

  # Main function

  @spec interfield_centroids(GEOF.Planet.Geometry.FieldCentroids.centroid_sphere(), integer) ::
          interfield_centroid_sphere

  def interfield_centroids(centroids, divisions) when is_integer(divisions) and divisions > 0 do
    for_all_fields(
      Map.new(),
      divisions,
      fn sphere, index ->
        set_interfield_centroids_for_responsible_field(sphere, centroids, divisions, index)
      end
    )
  end

  # Computes centroids for the two triangles all nonpolar fields are responsible for setting.

  defp set_interfield_centroids_for_responsible_field(sphere, centroids, d, {:sxy, s, x, y}) do
    index = {:sxy, s, x, y}
    adj = adjacents(index, d)

    t1 = [adj.w, adj.nw, index]
    t2 = [adj.sw, adj.w, index]

    sphere
    |> set_position(t1, centroid(Enum.map(t1, fn index -> Map.get(centroids, index) end)))
    |> set_position(t2, centroid(Enum.map(t2, fn index -> Map.get(centroids, index) end)))
  end

  # Ignore polar fields, which are not responsible for any triangles.

  defp set_interfield_centroids_for_responsible_field(sphere, _, _, _) do
    sphere
  end
end
