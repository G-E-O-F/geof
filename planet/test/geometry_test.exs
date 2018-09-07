defmodule GEOF.Planet.GeometryTest do
  use ExUnit.Case

  import :math
  import GEOF.Planet.Geometry
  import GEOF.Planet.Geometry.FieldCentroids, only: [l: 0]

  doctest GEOF.Planet.Geometry

  test "computes distance" do
    a = 2 * pi() / 5

    north = {:pos, pi() / 2, 0}
    ref_first = {:pos, pi() / 2 - l(), 0}
    ref_second = {:pos, pi() / 2 - l(), a}

    # zero tolerance
    assert_in_delta distance(north, north), 0, 0
    assert_in_delta distance(north, ref_first), l(), tolerance()
    assert_in_delta distance(north, ref_second), l(), tolerance()
    assert_in_delta distance(ref_first, ref_second), l(), tolerance()
  end

  test "calls interpolate functions" do
    north = {:pos, pi() / 2, 0}
    ref_first = {:pos, pi() / 2 - l(), 0}

    results =
      interpolate(
        Map.new(),
        2,
        north,
        ref_first,
        fn acc, i, pos ->
          Map.put(acc, i, pos)
        end
      )

    assert {:ok, {:pos, middle_lat, _}} = Map.fetch(results, 1)
    assert_in_delta middle_lat, pi() / 2 - l() / 2, tolerance()
  end

  test "computes centroids" do
    # Find the centroid of a triangle with all right angles (oh, noneuclidian geometry…)
    result_centroid =
      centroid([
        {:pos, pi() / 2, 0.0},
        {:pos, 0.0, 0.0},
        {:pos, 0.0, pi() / 2}
      ])

    assert {:pos, lat, lon} = result_centroid
    assert_in_delta lat, asin(1 / 3 / sqrt(1 / 3)), tolerance()
    assert_in_delta lon, pi() / 4, tolerance()
  end
end
