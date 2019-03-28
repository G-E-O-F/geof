defmodule GEOF.Planet.Patterns do
  alias GEOF.Planet.{
    Sphere,
    Geometry.FieldCentroids
  }

  @moduledoc """
    Functions for transforming field data into colors.
  """

  @doc "Produce an integer value that can be converted into an 8-bit RGB color."

  def int_to_color(int) do
    cond do
      int > 16_777_215 -> 16_777_215
      int < 0 -> 0
      is_integer(int) -> int
      true -> 0
    end
  end
end
