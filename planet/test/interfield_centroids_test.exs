defmodule PLANET.Geometry.InterfieldCentroidsTest do
  use ExUnit.Case

  import PLANET.Geometry.InterfieldCentroids

  doctest PLANET.Geometry.InterfieldCentroids

  test "computes interfield centroids" do
    interfield_centroid_sphere = interfield_centroids(3)

    # Check that we can access centroids from any 3 indexes of any order

    assert {:ok, {:pos, c1_lat, c1_lon}} =
             Map.fetch(
               interfield_centroid_sphere,
               MapSet.new([
                 :north,
                 {:sxy, 0, 0, 0},
                 {:sxy, 1, 0, 0}
               ])
             )

    assert {:ok, {:pos, c2_lat, c2_lon}} =
             Map.fetch(
               interfield_centroid_sphere,
               MapSet.new([
                 {:sxy, 0, 0, 0},
                 :north,
                 {:sxy, 1, 0, 0}
               ])
             )

    # Assert that the accessed centroids are identical

    assert c1_lat == c2_lat
    assert c1_lon == c2_lon
  end
end
