defmodule PLANET.GeometryTest do
  use ExUnit.Case

  import :math
  import PLANET.Geometry

  doctest PLANET.Geometry

  test "computes distance correctly" do
    # It appears Elixir is able to compute these values
    # more precicesly than JS (whose delta is 1.0e-12)
    tolerance = 1.111e-15

    a = 2 * pi() / 5

    north = {:pos, pi() / 2 + 1.0e-15, 1.0e-15}
    ref_first = {:pos, pi() / 2 - l(), 0}
    ref_second = {:pos, pi() / 2 - l(), a}

    # zero tolerance
    assert_in_delta distance(north, north), 0, 0
    assert_in_delta distance(north, ref_first), l(), tolerance
    assert_in_delta distance(north, ref_second), l(), tolerance
    assert_in_delta distance(ref_first, ref_second), l(), tolerance
  end

  # TODO: test actual functionality
  test "calls interpolate function as expected" do
    north = {:pos, pi() / 2 + 1.0e-15, 1.0e-15}
    ref_first = {:pos, pi() / 2 - l(), 0}

    results =
      interpolate(
        north,
        ref_first,
        2,
        fn i, pos, acc ->
          Map.put(acc, i, pos)
        end,
        Map.new()
      )

    assert {:ok, _} = Map.fetch(results, 1)
  end

  test "creates centroid maps" do
    sphere = centroids(2)
    assert {:ok, _} = Map.fetch(sphere, {:sxy, 3, 3, 0})
  end
end
