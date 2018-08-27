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

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}

  @doc "Returns the arclength between two points on the sphere"
  @spec distance(position, position) :: float

  def distance({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon}) do
    2 *
      asin(
        sqrt(
          pow(sin((f1_lat - f2_lat) / 2), 2) +
            cos(f1_lat) * cos(f2_lat) * pow(sin((f1_lon - f2_lon) / 2), 2)
        )
      )
  end

  @doc "Returns the heading and distance from the first position to the second position"
  @spec course(position, position) :: course

  def course({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon}) do
    d = distance({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon})
    a_relative = acos((sin(f2_lat) - sin(f1_lat) * cos(d)) / (sin(d) * cos(f1_lat)))

    a = if sin(f2_lon - f1_lon) < 0, do: a_relative, else: 2 * pi() - a_relative

    {:course, a, d}
  end
end
