defmodule GEOF.Planet.Geometry.FieldMeshTest do
  use ExUnit.Case

  import GEOF.Planet.Geometry.FieldMesh

  doctest GEOF.Planet.Geometry.FieldMesh

  test "produces the accumulator" do
    d = 3
    n_polys = 10 * d * d + 2
    n_faces = n_polys * 4 - 12
    mesh = field_mesh(d)
    assert length(mesh[:index]) == n_faces * 3
  end
end
