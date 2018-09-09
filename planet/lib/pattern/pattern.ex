defmodule GEOF.Planet.Pattern do
  import GEOF.Planet.Sphere

  @moduledoc """
    Functions for producing colors across the sphere model.
  """

  @type color :: {:rgb, integer, integer, integer}
  @type frame :: %{GEOF.Planet.Field.index() => color}

  def highlight_icosahedron(divisions) do
    d = divisions
    c1 = {:rgb, 215, 114, 33}
    c2 = {:rgb, 112, 0, 0}

    for_all_fields(%{}, divisions, fn
      acc, :north ->
        Map.put(acc, :north, c2)

      acc, :south ->
        Map.put(acc, :south, c2)

      acc, {:sxy, s, x, y} ->
        cond do
          rem(x + y + 1, d) == 0 or rem(x + 1, d) == 0 or y == 0 ->
            Map.put(acc, {:sxy, s, x, y}, c2)

          true ->
            Map.put(acc, {:sxy, s, x, y}, c1)
        end
    end)
  end
end
