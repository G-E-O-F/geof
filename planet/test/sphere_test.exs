defmodule GEOF.Planet.SphereTest do
  use ExUnit.Case

  import GEOF.Planet.Sphere

  doctest GEOF.Planet.Sphere

  test "iterates through indices properly" do
    d = 7

    n_fields =
      for_all_fields(0, d, fn acc, _ ->
        acc + 1
      end)

    assert n_fields == 10 * d * d + 2

    n_nonpolar_fields =
      for_all_fields(0, d, fn
        acc, {:sxy, _, _, _} -> acc + 1
        acc, _ -> acc
      end)

    assert n_nonpolar_fields == 10 * d * d
  end
end
