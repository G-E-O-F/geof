defmodule GEOF.Planet.Geometry.FieldCentroidsTest do
  use ExUnit.Case

  import :math
  import GEOF.Planet.Geometry
  import GEOF.Planet.Geometry.FieldCentroids

  doctest GEOF.Planet.Geometry.FieldCentroids

  test "computes centroid maps for an icosahedron (divisions = 1)" do
    icosahedron = field_centroids(1)

    # Confirm polar field centroid accuracy
    assert {:ok, {:pos, north_lat, 0.0}} = Map.fetch(icosahedron, :north)
    assert_in_delta north_lat, pi() / 2, tolerance()

    assert {:ok, {:pos, south_lat, 0.0}} = Map.fetch(icosahedron, :south)
    assert_in_delta south_lat, pi() / -2, tolerance()

    # Test polar fields
    assert {:pos, n_lat, n_lon} = Map.get(icosahedron, :north)
    assert_in_delta n_lat, pi() / 2, tolerance()
    assert_in_delta n_lon, 0, tolerance()

    assert {:pos, s_lat, s_lon} = Map.get(icosahedron, :south)
    assert_in_delta s_lat, pi() / -2, tolerance()
    assert_in_delta s_lon, 0, tolerance()

    # Test tropical fields
    assert {:pos, t1_lat, t1_lon} = Map.get(icosahedron, {:sxy, 2, 0, 0})
    assert_in_delta t1_lat, pi() / 2 - l(), tolerance()
    assert_in_delta t1_lon, 4 * pi() / 5, tolerance()

    assert {:pos, t2_lat, t2_lon} = Map.get(icosahedron, {:sxy, 2, 1, 0})
    assert_in_delta t2_lat, pi() / -2 + l(), tolerance()
    assert_in_delta t2_lon, 4 * pi() / 5 + pi() / 5, tolerance()

    # There should not be fields that would be out of bounds for an icosahedron
    assert :error = Map.fetch(icosahedron, {:sxy, 3, 2, 0})
  end

  test "creates centroid maps for an icosahedron with more than one subdivision" do
    d = 3
    sphere = field_centroids(d)
    u = l() / d
    a = 2 * pi() / 5

    # Test northern polar edge fields
    assert {:pos, np_lat, np_lon} = Map.get(sphere, {:sxy, 2, 1, 0})
    assert_in_delta np_lat, pi() / 2 - l() + u, tolerance()
    assert_in_delta np_lon, 4 * pi() / 5, tolerance()

    # Test second edge fields
    assert {:course, e2_a, e2_d} =
             course(
               Map.get(sphere, {:sxy, 2, 2, 0}),
               Map.get(sphere, {:sxy, 2, 1, 1})
             )

    assert_in_delta e2_a, a, tolerance()
    assert_in_delta e2_d, u, tolerance()

    # Test third edge fields
    assert {:course, e3_a, e3_d} =
             course(
               Map.get(sphere, {:sxy, 2, 2, 0}),
               Map.get(sphere, {:sxy, 2, 2, 1})
             )

    assert_in_delta e3_a, 2 * a, tolerance()
    assert_in_delta e3_d, u, tolerance()

    # Test fourth edge fields
    assert {:course, e4_a, e4_d} =
             course(
               Map.get(sphere, {:sxy, 2, 5, 0}),
               Map.get(sphere, {:sxy, 2, 4, 1})
             )

    assert_in_delta e4_a, pi() - a, tolerance()
    assert_in_delta e4_d, u, tolerance()

    # Test southern polar edge fields
    assert {:pos, sp_lat, sp_lon} = Map.get(sphere, {:sxy, 2, 5, 1})
    assert_in_delta sp_lat, pi() / -2 + l() - u, tolerance()
    assert_in_delta sp_lon, pi(), tolerance()
  end
end
