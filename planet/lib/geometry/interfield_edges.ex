defmodule GEOF.Planet.Geometry.InterfieldEdges do
  @moduledoc """
    Functions for computing the arclengths of the edges between the centroid of each
    Field on a Sphere. This is effectively a set of vertex pairs that could be used to construct a
    wireframe of the so called "dual" sphere, a Delaunay triangulation of the "primal" sphere.

    Unless some form of centroid correction has been applied (e.g. the planned Heikes-Randall
    smoothing), these arclengths should all equal `L / divisions` within a certain tiny delta.
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

  @typedoc "`interfield_edge`s are identified by the Fields whose centroids define their vertices."

  @type interfield_edge_index :: MapSet.t(Field.index())

  @typedoc "Maps `interfield_edge`s to their arclengths."

  @type interfield_edge_sphere :: %{
          required(interfield_edge_index) => float
        }

  ###
  #
  # FUNCTIONS
  #
  ###

  ##
  # Utility functions
  ##

  # Adds a new entry to an `interfield_edge_sphere`.

  @spec set_length(
          interfield_edge_sphere,
          interfield_edge_index,
          float
        ) :: interfield_edge_sphere

  defp set_length(sphere, edge_index, arclength) do
    Map.put(sphere, edge_index, arclength)
  end

  ##
  # Interfield-edge sphere computation
  ##

  # Convenience function without need for a `centroid_sphere`

  @doc """
    Computes a new `interfield_edge_sphere`, computing its own `centroid_sphere`.
    Deprecated outside of testing and examples.
  """

  @spec interfield_edges(Sphere.divisions()) :: interfield_edge_sphere

  def interfield_edges(divisions) when is_integer(divisions) and divisions > 0 do
    interfield_edges(
      FieldCentroids.field_centroids(divisions),
      divisions
    )
  end

  # Main function

  @doc "Computes a new `interfield_edge_sphere` with the provided `centroid_sphere`."

  @spec interfield_edges(FieldCentroids.centroid_sphere(), Sphere.divisions()) ::
          interfield_edge_sphere

  def interfield_edges(centroid_sphere, divisions) do
    Sphere.for_all_fields(
      Map.new(),
      divisions,
      fn sphere, index ->
        set_interfield_edges_for_field(sphere, centroid_sphere, divisions, index)
      end
    )
  end

  defp set_interfield_edges_for_field(sphere, centroid_sphere, d, index) do
    adj = Field.adjacents(index, d)
    # todo: optimize this; surely you can determine which edges a field is responsible for.
    Enum.reduce(adj, sphere, fn {_dir, adj_index}, sphere ->
      edge_index = MapSet.new([adj_index, index])

      cond do
        Map.has_key?(sphere, edge_index) ->
          sphere

        true ->
          set_length(
            sphere,
            edge_index,
            Geometry.distance(
              centroid_sphere[adj_index],
              centroid_sphere[index]
            )
          )
      end
    end)
  end
end
