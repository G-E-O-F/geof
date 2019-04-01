defmodule GEOF.Planet.Geometry.FieldEdges do
  @moduledoc """
    Functions for computing the arclengths of the edges between interfield centroids, a.k.a. field
    vertices. This is effectively a set of vertex pairs that could be used to construct a
    wireframe of the so called "primal" sphere, a hexagonal–icosahedral Voronoi grid.
  """

  alias GEOF.Planet.{
    Sphere,
    Field,
    Geometry,
    Geometry.InterfieldCentroids
  }

  @pent_adj_order [:sw, :se, :e, :nw, :w]
  @hex_adj_order [:sw, :se, :e, :ne, :nw, :w]

  ###
  #
  # TYPES
  #
  ###

  @typedoc "`field_edge`s are identified by the two interfield centroid indices that define their vertices."

  @type field_edge_index :: MapSet.t(InterfieldCentroids.interfield_triangle_index())

  @typedoc "Maps `interfield_edge`s to their arclengths."

  @type field_edge_sphere :: %{
          required(field_edge_index) => float
        }

  ###
  #
  # FUNCTIONS
  #
  ###

  ##
  # Utility functions
  ##

  # Adds a new entry to a `field_edge_sphere`.

  @spec set_length(
          field_edge_sphere,
          field_edge_index,
          float
        ) :: field_edge_sphere

  defp set_length(sphere, field_edge_index, arclength) do
    Map.put(sphere, field_edge_index, arclength)
  end

  ##
  # Field-edge sphere computation
  ##

  # Convenience function without need for a `interfield_centroid_sphere`

  @doc """
    Computes a new `interfield_edge_sphere`, computing its own `interfield_centroid_sphere` (which in turn computes its own `centroid_sphere`)
    Deprecated outside of testing and examples.
  """

  @spec field_edges(Sphere.divisions()) :: field_edge_sphere

  def field_edges(divisions) when is_integer(divisions) and divisions > 0 do
    field_edges(
      InterfieldCentroids.interfield_centroids(divisions),
      divisions
    )
  end

  # Main function

  @doc "Computes a new `field_edge_sphere` with the provided `interfield_centroid_sphere`."

  @spec field_edges(InterfieldCentroids.interfield_centroid_sphere(), Sphere.divisions()) ::
          field_edge_sphere

  def field_edges(interfield_centroid_sphere, divisions) do
    Sphere.for_all_fields(
      Map.new(),
      divisions,
      fn sphere, field_index ->
        set_field_edges_for_field(sphere, interfield_centroid_sphere, divisions, field_index)
      end
    )
  end

  defp set_field_edges_for_field(sphere, interfield_centroid_sphere, d, field_index) do
    adj = Field.adjacents(field_index, d)

    sides = if Map.has_key?(adj, :ne), do: 6, else: 5

    adj_order =
      cond do
        sides == 5 -> @pent_adj_order
        sides == 6 -> @hex_adj_order
      end

    Enum.reduce(
      0..if(field_index == :north or field_index == :south, do: 4, else: sides - 4),
      sphere,
      fn s, sphere ->
        s_0 = rem(s + sides, sides)
        s_1 = rem(s + sides + 1, sides)
        s_2 = rem(s + sides + 2, sides)

        v_0 =
          MapSet.new([
            field_index,
            Map.get(adj, Enum.at(adj_order, s_0)),
            Map.get(adj, Enum.at(adj_order, s_1))
          ])

        v_1 =
          MapSet.new([
            field_index,
            Map.get(adj, Enum.at(adj_order, s_1)),
            Map.get(adj, Enum.at(adj_order, s_2))
          ])

        field_edge_index = MapSet.new([v_0, v_1])

        set_length(
          sphere,
          field_edge_index,
          Geometry.distance(
            interfield_centroid_sphere[v_0],
            interfield_centroid_sphere[v_1]
          )
        )
      end
    )
  end
end
