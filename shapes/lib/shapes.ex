defmodule GEOF.Shapes do
  @moduledoc """
    Functions for working with shapes.
  """

  @type vector :: {number, number, number}
  @type line :: {vector, vector}
  @type triangle :: {vector, vector, vector}

  @spec line_intersects_triangle?(line, triangle) :: boolean

  def line_intersects_triangle?({l_a, l_b}, {p_0, p_1, p_2}) do
    l_ab = Vector.subtract(l_a, l_b)
    inv_l_ab = Vector.reverse(l_ab)

    p_01 = Vector.subtract(p_1, p_0)
    p_02 = Vector.subtract(p_2, p_0)

    p_01x02 = Vector.cross(p_01, p_02)
    l_a_minus_p_0 = Vector.subtract(l_a, p_0)

    determinant = Vector.dot(inv_l_ab, p_01x02)

    # In case you want the `t` component later:
    # t =
    #  Vector.dot(
    #    p_01x02,
    #    l_a_minus_p_0
    #  ) / determinant

    u =
      Vector.dot(
        Vector.cross(
          p_02,
          inv_l_ab
        ),
        l_a_minus_p_0
      ) / determinant

    v =
      Vector.dot(
        Vector.cross(
          inv_l_ab,
          p_01
        ),
        l_a_minus_p_0
      ) / determinant

    u >= 0 and v >= 0 and u <= 1 and v <= 1 and u + v <= 1
  end
end
