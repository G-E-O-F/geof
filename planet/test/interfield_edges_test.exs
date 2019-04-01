defmodule GEOF.Planet.Geometry.InterfieldEdgesTest do
  use ExUnit.Case

  import GEOF.Planet.Geometry
  import GEOF.Planet.Geometry.InterfieldEdges
  import GEOF.Planet.Geometry.FieldCentroids, only: [l: 0]

  doctest GEOF.Planet.Geometry.InterfieldEdges

  test "computes edge maps for an icosahedron (divisions = 1)" do
    icosahedron_edges = interfield_edges(1)

    # There are 30 edges in an icosahedron
    assert map_size(icosahedron_edges) == 30
    # Each of the edges should equal L
    assert_in_delta icosahedron_edges[MapSet.new([:north, {:sxy, 0, 0, 0}])], l(), tolerance()
  end

  # todo: test the general case, once you figure it out.
end
