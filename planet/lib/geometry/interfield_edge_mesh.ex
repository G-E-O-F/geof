defmodule GEOF.Planet.Geometry.InterfieldEdgeMesh do
  @moduledoc """
    Functions for translating a Planet's "dual" Delaunay triangulation grid into a wireframe.
  """

  import :math

  alias GEOF.Planet.{
    Sphere,
    Geometry.FieldCentroids,
    Geometry.InterfieldEdges
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

  @doc "Produces an `edge_mesh` for the dual sphere. Convenience function."

  @spec interfield_edge_mesh(Sphere.divisions()) :: edge_mesh

  def interfield_edge_mesh(divisions) do
    centroid_sphere = FieldCentroids.field_centroids(divisions)

    interfield_edge_mesh(
      centroid_sphere,
      InterfieldEdges.interfield_edges(centroid_sphere, divisions)
    )
  end

  # Main function

  @doc "Produces an `edge_mesh` for the dual sphere."

  @spec interfield_edge_mesh(
          FieldCentroids.centroid_sphere(),
          InterfieldEdges.interfield_edge_sphere()
        ) :: edge_mesh

  def interfield_edge_mesh(centroid_sphere, interfield_edge_sphere) do
    centroid_positions =
      Enum.reduce(
        centroid_sphere,
        [
          position: [],
          index_map: %{},
          pos_c: 0
        ],
        fn {field_index, {:pos, lat, lon}}, acc ->
          x = cos(lat) * cos(lon)
          z = cos(lat) * sin(lon)
          y = sin(lat)

          [
            position: [z | [y | [x | acc[:position]]]],
            index_map: Map.put(acc[:index_map], field_index, acc[:pos_c]),
            pos_c: acc[:pos_c] + 1
          ]
        end
      )

    index =
      Enum.reduce(interfield_edge_sphere, [], fn {interfield_edge_index, _pos}, index ->
        Enum.reduce(interfield_edge_index, index, fn field_index, index ->
          [centroid_positions[:index_map][field_index] | index]
        end)
      end)

    [
      position: Enum.reverse(centroid_positions[:position]),
      index: Enum.reverse(index)
    ]
  end
end
