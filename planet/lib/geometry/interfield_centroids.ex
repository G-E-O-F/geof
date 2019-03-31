defmodule GEOF.Planet.Geometry.InterfieldCentroids do
  @moduledoc """
    Functions for computing the positions of the centroids between each
    Field on a Sphere. This is used to determine the vertices of a
    field's bounding polygon.
  """

  alias GEOF.Planet.{
    Sphere,
    Field,
    Geometry,
    Geometry.FieldCentroids
  }

  ###
  #
  # TYPES
  #
  ###

  @typedoc "`interfield_triangle`s are identified by the Fields whose centroids define their vertices."

  @type interfield_triangle_index :: MapSet.t(Field.index())

  @typedoc "Maps `interfield_triangle`s to the `position`s of their centroids."

  @type interfield_centroid_sphere :: %{
          required(interfield_triangle_index) => Geometry.position()
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

  # Adds a new entry to an `interfield_centroid_sphere`.

  @spec set_position(
          interfield_centroid_sphere,
          list(Field.index()),
          Geometry.position()
        ) :: interfield_centroid_sphere

  defp set_position(sphere, [index1, index2, index3], {:pos, lat, lon}) do
    Map.put(sphere, MapSet.new([index1, index2, index3]), {:pos, lat, lon})
  end

  ##
  # Interfield-centroid sphere computation
  ##

  # Convenience function without need for a `centroid_sphere`

  @doc """
    Computes a new `interfield_centroid_sphere`, computing its own `centroid_sphere`.
    Deprecated outside of testing and examples.
  """

  @spec interfield_centroids(Sphere.divisions()) :: interfield_centroid_sphere

  def interfield_centroids(divisions) when is_integer(divisions) and divisions > 0 do
    interfield_centroids(
      FieldCentroids.field_centroids(divisions),
      divisions
    )
  end

  # Main function

  @doc "Computes a new `interfield_centroid_sphere` with the provided `centroid_sphere`."

  @spec interfield_centroids(FieldCentroids.centroid_sphere(), Sphere.divisions()) ::
          interfield_centroid_sphere

  def interfield_centroids(centroid_sphere, divisions)
      when is_integer(divisions) and divisions > 0 do
    Sphere.for_all_fields(
      Map.new(),
      divisions,
      fn sphere, index ->
        set_interfield_centroids_for_responsible_field(sphere, centroid_sphere, divisions, index)
      end
    )
  end

  # Computes centroids for the two triangles all non-polar fields are responsible for setting.

  defp set_interfield_centroids_for_responsible_field(sphere, centroids, d, {:sxy, s, x, y}) do
    index = {:sxy, s, x, y}
    adj = Field.adjacents(index, d)

    t1 = [adj.w, adj.nw, index]
    t2 = [adj.sw, adj.w, index]

    sphere
    |> set_position(
      t1,
      Geometry.centroid(Enum.map(t1, fn index -> Map.get(centroids, index) end))
    )
    |> set_position(
      t2,
      Geometry.centroid(Enum.map(t2, fn index -> Map.get(centroids, index) end))
    )
  end

  # Ignore polar fields, which are not responsible for any triangles.

  defp set_interfield_centroids_for_responsible_field(sphere, _, _, _) do
    sphere
  end
end
