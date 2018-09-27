defmodule GEOF.Shapes do
  @moduledoc """
    Functions for working with shapes.
  """

  import :math

  @type vector :: {number, number, number}
  @type line :: {vector, vector}
  @type triangle :: {vector, vector, vector}

  @spec line_intersects_triangle?(line, triangle) :: boolean

  def line_intersects_triangle?({l_a, l_b}, {p_0, p_1, p_2}) do
    l_ab = Vector.subtract(l_a, l_b)
    inverse_l_ab = Vector.reverse(l_ab)

    p_01 = Vector.subtract(p_1, p_0)
    p_02 = Vector.subtract(p_2, p_0)

    p_01x02 = Vector.cross(p_01, p_02)
    l_a_minus_p_0 = Vector.subtract(l_a, p_0)

    determinant = Vector.dot(inverse_l_ab, p_01x02)

    if determinant == 0 do
      false
    else
      t =
        Vector.dot(
          p_01x02,
          l_a_minus_p_0
        ) / determinant

      u =
        Vector.dot(
          Vector.cross(
            p_02,
            inverse_l_ab
          ),
          l_a_minus_p_0
        ) / determinant

      v =
        Vector.dot(
          Vector.cross(
            inverse_l_ab,
            p_01
          ),
          l_a_minus_p_0
        ) / determinant

      u >= 0 and v >= 0 and u + v <= 1 and t <= 0
    end
  end

  @spec face_of_4_hedron(GEOF.Planet.Geometry.position()) :: integer

  @ir3 1 / sqrt(3)

  @tetrahedron_in_unit_sphere {
    [
      # vectors
      {@ir3, @ir3, @ir3},
      {-@ir3, @ir3, -@ir3},
      {-@ir3, -@ir3, @ir3},
      {@ir3, -@ir3, -@ir3}
    ],
    [
      # faces
      [1, 3, 2],
      [0, 2, 3],
      [0, 3, 1],
      [0, 2, 1]
    ]
  }

  @tetrahedron_triangles (fn ->
                            {tetr_vects, tetr_faces} = @tetrahedron_in_unit_sphere

                            Enum.map(tetr_faces, fn face ->
                              {
                                Enum.at(tetr_vects, Enum.at(face, 0)),
                                Enum.at(tetr_vects, Enum.at(face, 1)),
                                Enum.at(tetr_vects, Enum.at(face, 2))
                              }
                            end)
                          end).()

  def face_of_4_hedron({:pos, lat, lon}) do
    x = cos(lat) * cos(lon)
    y = cos(lat) * sin(lon)
    z = sin(lat)

    line = {
      {0, 0, 0},
      Vector.multiply({x, y, z}, 1.1)
    }

    Enum.find_index(@tetrahedron_triangles, fn triangle ->
      line_intersects_triangle?(line, triangle)
    end)
  end
end
