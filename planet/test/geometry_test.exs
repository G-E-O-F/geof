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

    assert {:ok, {:pos, middle_lat, _}} = Map.fetch(results, 1)
    assert_in_delta middle_lat, pi() / 2 - l() / 2, @tolerance
  end

  test "creates centroid maps for an icosahedron" do
    icosahedron = centroids(1)

    #    IO.puts("[icosahedron]")
    #    IO.inspect(icosahedron)

    # Confirm polar field centroid accuracy
    assert {:ok, {:pos, north_lat, 0.0}} = Map.fetch(icosahedron, :north)
    assert_in_delta north_lat, pi() / 2, @tolerance

    assert {:ok, {:pos, south_lat, 0.0}} = Map.fetch(icosahedron, :south)
    assert_in_delta south_lat, pi() / -2, @tolerance

    # TODO: test tropical fields
    assert {:ok, {:pos, _, _}} = Map.fetch(icosahedron, {:sxy, 3, 1, 0})

    # There should not be fields that would be out of bounds for an icosahedron
    assert :error = Map.fetch(icosahedron, {:sxy, 3, 2, 0})
  end

  test "creates centroid maps for an icosahedron with one subdivision" do
    simple_sphere = centroids(2)

    #    IO.puts("[sphere]")
    #    IO.inspect(sphere)

    # TODO: test fields on edges
    assert {:ok, {:pos, _, _}} = Map.fetch(simple_sphere, {:sxy, 3, 3, 0})
  end

  test "creates centroid maps for an icosahedron with more than one subdivision" do
    complex_sphere = centroids(3)

    #            IO.puts("[sphere]")
    #            IO.inspect(complex_sphere)

    # TODO: test fields between edges
    assert {:ok, {:pos, _, _}} = Map.fetch(complex_sphere, {:sxy, 2, 5, 2})
  end
end
