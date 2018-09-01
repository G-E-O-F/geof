defmodule PLANET.Geometry do
  import :math

  ###
  #
  # TYPES
  #
  ###

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}

  ###
  #
  # FUNCTIONS
  #
  ###

  ##
  # Basic spherical geometry
  ##

  @doc "Returns the arclength between two points on the sphere."
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

  @doc """
    Calls the `into` callback function `divisions`-1 times, once for each
    point spaced evenly between two points on the sphere, and reduces the
    `init_acc` into a final value.
  """
  @spec interpolate(any, integer, position, position, fun) :: {:ok}

  def interpolate(init_acc, divisions, pos_1, pos_2, into)
      when is_integer(divisions) and divisions > 1 do
    Enum.reduce(1..(divisions - 1), init_acc, fn i, acc ->
      interpolate_step(acc, divisions, pos_1, pos_2, into, i)
    end)
  end

  def interpolate(init_acc, _, _, _, _) do
    init_acc
  end

  defp interpolate_step(acc, d, pos_1, pos_2, into, i) do
    {:pos, f1_lat, f1_lon} = pos_1
    {:pos, f2_lat, f2_lon} = pos_2

    f = i / d
    d = distance(pos_1, pos_2)

    a = sin((1 - f) * d) / sin(d)
    b = sin(f * d) / sin(d)

    x = a * cos(f1_lat) * cos(f1_lon) + b * cos(f2_lat) * cos(f2_lon)
    z = a * cos(f1_lat) * sin(f1_lon) + b * cos(f2_lat) * sin(f2_lon)
    y = a * sin(f1_lat) + b * sin(f2_lat)

    lat = atan2(y, sqrt(pow(x, 2) + pow(z, 2)))
    lon = atan2(z, x)

    into.(acc, i, {:pos, lat, lon})
  end
end
