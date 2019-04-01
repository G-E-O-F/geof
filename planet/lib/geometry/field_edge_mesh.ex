defmodule GEOF.Planet.Geometry.FieldEdgeMesh do
  @moduledoc """
    Functions for translating a Planet's primal Voronoi geometry into a wireframe.
  """

  import :math

  alias GEOF.Planet.{
    Geometry.FieldEdges,
    Geometry.InterfieldCentroids
  }

  ###
  #
  # TYPES
  #
  ###

  @typedoc "The payload given to the 3D environment."

  @type edge_mesh :: [
          position: nonempty_list(float),
          index: nonempty_list(non_neg_integer)
        ]

  ###
  #
  # FUNCTIONS
  #
  ###

  # Convenience function

  @doc "Produces an `edge_mesh` with two line segments for each non-polar field. Convenience function."

  @spec field_edge_mesh(Sphere.divisions()) :: edge_mesh

  def field_edge_mesh(divisions) do
    interfield_centroid_sphere = InterfieldCentroids.interfield_centroids(divisions)

    field_edge_mesh(
      interfield_centroid_sphere,
      FieldEdges.field_edges(interfield_centroid_sphere, divisions)
    )
  end

  # Main function

  @doc "Produces an `edge_mesh` with two line segments for each non-polar field."

  @spec field_edge_mesh(
          InterfieldCentroids.interfield_centroid_sphere(),
          FieldEdges.field_edge_sphere()
        ) :: edge_mesh

  def field_edge_mesh(interfield_centroid_sphere, field_edge_sphere) do
    interfield_positions =
      Enum.reduce(
        interfield_centroid_sphere,
        [
          position: [],
          index_map: %{},
          pos_c: 0
        ],
        fn {interfield_centroid_index, {:pos, lat, lon}}, acc ->
          x = cos(lat) * cos(lon)
          z = cos(lat) * sin(lon)
          y = sin(lat)

          [
            position: [z | [y | [x | acc[:position]]]],
            index_map: Map.put(acc[:index_map], interfield_centroid_index, acc[:pos_c]),
            pos_c: acc[:pos_c] + 1
          ]
        end
      )

    index =
      Enum.reduce(field_edge_sphere, [], fn {field_edge_index, _length}, index ->
        Enum.reduce(field_edge_index, index, fn interfield_centroid_index, index ->
          [interfield_positions[:index_map][interfield_centroid_index] | index]
        end)
      end)

    [
      position: Enum.reverse(interfield_positions[:position]),
      index: Enum.reverse(index)
    ]
  end
end
