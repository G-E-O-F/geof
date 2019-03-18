defmodule GEOF.Planet.Geometry.EdgeMesh do
  @moduledoc """
    Functions for translating a Planet's geometry into a wireframe.
  """

  import :math

  alias GEOF.Planet.{
    Sphere,
    Field,
    Geometry.FieldCentroids,
    Geometry.InterfieldCentroids
  }

  # The order of Field adjacent directions to process.

  @pent_adj_order [:sw, :se, :e, :nw, :w]
  @hex_adj_order [:sw, :se, :e, :ne, :nw, :w]

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

  @spec poly_per_field(Sphere.divisions()) :: edge_mesh

  def poly_per_field(divisions) do
    field_centroids = FieldCentroids.field_centroids(divisions)

    poly_per_field(
      divisions,
      field_centroids,
      InterfieldCentroids.interfield_centroids(field_centroids, divisions)
    )
  end

  # Main function

  @doc "Produces an `edge_mesh` with two line segments for each non-polar field."

  @spec poly_per_field(
          Sphere.divisions(),
          FieldCentroids.centroid_sphere(),
          InterfieldCentroids.interfield_centroid_sphere()
        ) :: edge_mesh

  def poly_per_field(divisions, _field_centroids, interfield_centroids) do
    d = divisions

    #    pos_size = map_size(interfield_centroids) - 1

    interfield_positions =
      Enum.reduce(
        interfield_centroids,
        [
          position: [],
          index_map: %{},
          pos_c: 0
        ],
        fn {field_index_set, {:pos, lat, lon}}, acc ->
          x = cos(lat) * cos(lon)
          z = cos(lat) * sin(lon)
          y = sin(lat)

          [
            position: [z | [y | [x | acc[:position]]]],
            index_map: Map.put(acc[:index_map], field_index_set, acc[:pos_c]),
            pos_c: acc[:pos_c] + 1
          ]
        end
      )

    index =
      Sphere.for_all_fields(
        [],
        d,
        fn acc, field_index ->
          adj = Field.adjacents(field_index, d)
          sides = if Map.has_key?(adj, :ne), do: 6, else: 5

          adj_order =
            cond do
              sides == 5 -> @pent_adj_order
              sides == 6 -> @hex_adj_order
            end

          Enum.reduce(
            0..if(field_index == :north or field_index == :south, do: 4, else: sides - 4),
            acc,
            fn s, acc ->
              s_0 = rem(s + sides, sides)
              s_1 = rem(s + sides + 1, sides)
              s_2 = rem(s + sides + 2, sides)

              i_0 =
                Map.get(
                  interfield_positions[:index_map],
                  MapSet.new([
                    field_index,
                    Map.get(adj, Enum.at(adj_order, s_0)),
                    Map.get(adj, Enum.at(adj_order, s_1))
                  ])
                )

              i_1 =
                Map.get(
                  interfield_positions[:index_map],
                  MapSet.new([
                    field_index,
                    Map.get(adj, Enum.at(adj_order, s_1)),
                    Map.get(adj, Enum.at(adj_order, s_2))
                  ])
                )

              [i_1 | [i_0 | acc]]
            end
          )
        end
      )

    [
      position: Enum.reverse(interfield_positions[:position]),
      index: Enum.reverse(index)
    ]
  end
end
