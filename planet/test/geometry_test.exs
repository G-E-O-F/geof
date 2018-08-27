defmodule PLANET.GeometryTest do
  use ExUnit.Case

  import :math
  import PLANET.Geometry

  doctest PLANET.Geometry

  test "computes distance correctly" do
    a = 2 * pi() / 5

    north = {:pos, pi() / 2 + 1.0e-15, 1.0e-15}
    ref_first = {:pos, pi() / 2 - l(), 0}
    ref_second = {:pos, pi() / 2 - l(), a}

    assert_in_delta distance(north, north), 0, 0
    assert_in_delta distance(north, ref_first), l(), 1.0e-14
    assert_in_delta distance(ref_first, ref_second), l(), 1.0e-14
  end
end
