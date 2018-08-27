defmodule PLANET.Geometry do
  import :math

  @moduledoc """
    PLANET.Geometry contains the mathematical functions necessary to
    compute the positional information for a Planet's Fields.
  """

  #  @doc "The number of 2d arrays across the surface"
  #  @peels 5

  @doc "The arclength of an edge of an icosahedron"
  @l acos(sqrt(5) / 5)
  def l, do: @l

  @doc "Returns the arclength between two points on the sphere"
  def distance({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon}) do
    2 *
      asin(
        sqrt(
          pow(sin((f1_lat - f2_lat) / 2), 2) +
            cos(f1_lat) * cos(f2_lat) * pow(sin((f1_lon - f2_lon) / 2), 2)
        )
      )
  end
end
