defmodule GEOF.Planet.Geometry.Mesh do
  import GEOF.Planet.Sphere
  import GEOF.Planet.Field
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
    field_centroids = GEOF.Planet.Geometry.FieldCentroids.field_centroids(divisions)

    poly_per_field(
      divisions,
      field_centroids,
      GEOF.Planet.Geometry.InterfieldCentroids.interfield_centroids(field_centroids, divisions)
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
          vertex_order: %{},
          pos_c: 0,
          buffer_i: 0
        ],
        d,
        fn acc, field_index ->
          pos_c = acc[:pos_c]
          adj = adjacents(field_index, d)
          sides = if adj.ne == nil, do: 5, else: 6

          {:pos, lat, lon} = Map.get(field_centroids, field_index)

          position =
            Enum.reduce(
              0..(sides - 1),
              acc[:position],
              fn s, acc ->
                next_s = rem(s + sides + 1, sides)

                {:xzy, x, z, y} =
                  Map.get(
                    interfield_cartesian_points,
                    MapSet.new([
                      field_index,
                      Map.get(adj, Enum.at(@adj_order, s)),
                      Map.get(adj, Enum.at(@adj_order, next_s))
                    ])
                  )

                [z | [y | [x | acc]]]
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
          normal =
            Enum.reduce(
              0..(sides - 1),
              acc[:normal],
              fn _, acc ->
                [x, y, z] = poly_normal
                [z | [y | [x | acc]]]
              end
            )

          index =
            cond do
              # :south is a special case; its faces must wind backwards
              field_index == :south ->
                Enum.reduce(@pent_faces_cw, acc[:index], fn f, acc -> [f + pos_c | acc] end)

              sides == 5 ->
                Enum.reduce(@pent_faces, acc[:index], fn f, acc -> [f + pos_c | acc] end)

              true ->
                Enum.reduce(@hex_faces, acc[:index], fn f, acc -> [f + pos_c | acc] end)
            end

          [
            position: position,
            normal: normal,
            index: index,
            vertex_order:
              Map.put(acc[:vertex_order], flatten_index(field_index, d), acc[:buffer_i]),
            pos_c: acc[:pos_c] + sides,
            buffer_i: acc[:buffer_i] + sides * 3
          ]
        end
      )

    [
      position: Enum.reverse(mesh_attr_buffers[:position]),
      normal: Enum.reverse(mesh_attr_buffers[:normal]),
      index: Enum.reverse(mesh_attr_buffers[:index]),
      vertex_order: mesh_attr_buffers[:vertex_order]
    ]
  end
end
