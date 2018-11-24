defmodule GEOF.Shapes.ShapesTest do
  use ExUnit.Case

  import GEOF.Shapes

  doctest GEOF.Shapes

  test "line-triangle intersections" do
    bullseye = {
      {1, 1, 0},
      {1, 0, 1},
      {1, 0, 0}
    }

    # A line that goes through the triangle
    line_1 = {
      {0, 0, 0},
      {2, 0.01, 0.01}
    }

    # A line that misses the triangle from edge 1
    line_2 = {
      {0, 0, 0},
      {2, -0.01, 0.01}
    }

    # A line that misses the triangle from edge 2
    line_3 = {
      {0, 0, 0},
      {2, 0.01, -0.01}
    }

    # A line that misses the triangle from edge 3
    line_4 = {
      {0, 0, 0},
      {2, 1.01, 1.01}
    }

    assert line_intersects_triangle?(line_1, bullseye)
    refute line_intersects_triangle?(line_2, bullseye)
    refute line_intersects_triangle?(line_3, bullseye)
    refute line_intersects_triangle?(line_4, bullseye)
  end
end
