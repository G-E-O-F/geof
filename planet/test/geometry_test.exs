defmodule PLANET.GeometryTest do
  use ExUnit.Case

  import :math
  import PLANET.Geometry

  doctest PLANET.Geometry

  # It appears Elixir is able to compute these values
  # more precicesly than JS (whose delta is 1.0e-12)
  @tolerance 1.111e-15

  test "computes distance correctly" do
    a = 2 * pi() / 5

    north = {:pos, pi() / 2, 0}
    ref_first = {:pos, pi() / 2 - l(), 0}
    ref_second = {:pos, pi() / 2 - l(), a}

    # zero tolerance
    assert_in_delta distance(north, north), 0, 0
    assert_in_delta distance(north, ref_first), l(), @tolerance
    assert_in_delta distance(north, ref_second), l(), @tolerance
    assert_in_delta distance(ref_first, ref_second), l(), @tolerance
  end

  test "calls interpolate function as expected" do
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

    assert {:ok, {:pos, middle_lat, middle_lon}} = Map.fetch(results, 1)
    assert_in_delta middle_lat, pi() / 2 - l() / 2, @tolerance
  end

  test "creates centroid maps" do
    sphere = centroids(2)

    IO.inspect(sphere)

    assert {:ok, {:pos, north_lat, 0}} = Map.fetch(sphere, :north)
    assert_in_delta north_lat, pi() / 2, @tolerance

    assert {:ok, {:pos, south_lat, 0}} = Map.fetch(sphere, :south)
    assert_in_delta south_lat, pi() / -2, @tolerance

    # TODO: test other fields more robustly
    assert {:ok, _} = Map.fetch(sphere, {:sxy, 3, 3, 0})
  end
end
