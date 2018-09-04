defmodule PLANET.Geometry.MeshTest do
  use ExUnit.Case

  import PLANET.Geometry.Mesh

  doctest PLANET.Geometry.Mesh

  test "produces the accumulator" do
    d = 3
    n_polys = 10 * d * d + 2
    n_faces = n_polys * 4 - 12
    mesh = poly_per_field(d)
    assert length(mesh[:index]) == n_faces * 3
  end
end
