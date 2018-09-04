defmodule PLANET.Geometry.Mesh do
  import PLANET.Sphere
  import PLANET.Field
  import :math

  @moduledoc """
    Functions for translating a Planet's geometry to data that
    can be used in WebGL etc.
  """

  @pent_faces [0, 2, 1, 0, 4, 2, 4, 3, 2]
  @pent_faces_cw [1, 2, 0, 2, 4, 0, 2, 3, 4]
  @hex_faces [0, 2, 1, 0, 3, 2, 0, 5, 3, 5, 4, 3]

  @adj_order [:nw, :w, :sw, :se, :e, :ne]

  # Convenience function

  def poly_per_field(divisions) do
    field_centroids = PLANET.Geometry.FieldCentroids.field_centroids(divisions)

    poly_per_field(
      divisions,
      field_centroids,
      PLANET.Geometry.InterfieldCentroids.interfield_centroids(field_centroids, divisions)
    )
  end

  # Main function

  def poly_per_field(divisions, field_centroids, interfield_centroids) do
    d = divisions

    interfield_cartesian_points =
      Enum.reduce(interfield_centroids, %{}, fn {field_index_set, {:pos, lat, lon}}, acc ->
        Map.put(acc, field_index_set, {:xzy, cos(lat) * cos(lon), cos(lat) * sin(lon), sin(lat)})
      end)

    mesh_attr_buffers =
      for_all_fields(
        [
          position: [],
          normal: [],
          index: [],
          pos_c: 0
        ],
        d,
        fn acc, index ->
          pos_c = acc[:pos_c]
          adj = adjacents(index, d)
          sides = if adj.ne == nil, do: 5, else: 6

          {:pos, lat, lon} = Map.get(field_centroids, index)

          poly_positions =
            Enum.reduce(
              0..(sides - 1),
              [],
              fn s, acc ->
                next_s = rem(s + sides + 1, sides)

                {:xzy, x, z, y} =
                  Map.get(
                    interfield_cartesian_points,
                    MapSet.new([
                      index,
                      Map.get(adj, Enum.at(@adj_order, s)),
                      Map.get(adj, Enum.at(@adj_order, next_s))
                    ])
                  )

                acc ++ [x, y, z]
              end
            )

          poly_normal = [
            # x
            cos(lat) * cos(lon),
            # y
            sin(lat),
            # z
            cos(lat) * sin(lon)
          ]

          # This repeats the same normal for each vertex
          poly_normals =
            Enum.reduce(
              0..(sides - 1),
              [],
              fn _, acc ->
                acc ++ poly_normal
              end
            )

          poly_indices =
            cond do
              # :south is a special case; its faces must wind backwards
              index == :south ->
                Enum.map(@pent_faces_cw, fn f -> f + pos_c end)

              sides == 5 ->
                Enum.map(@pent_faces, fn f -> f + pos_c end)

              true ->
                Enum.map(@hex_faces, fn f -> f + pos_c end)
            end

          [
            position: acc[:position] ++ poly_positions,
            normal: acc[:normal] ++ poly_normals,
            index: acc[:index] ++ poly_indices,
            pos_c: acc[:pos_c] + sides
          ]
        end
      )

    Keyword.delete(mesh_attr_buffers, :pos_c)
  end
end
