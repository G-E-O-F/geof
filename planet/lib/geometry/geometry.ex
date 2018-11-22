defmodule GEOF.Planet.Geometry do
  @moduledoc """
    Functions for computing a Planet's geometry.
  """

  import :math

  ###
  #
  # ATTRIBUTES
  #
  ###

  @doc "The apparent accuracy of Erlang's trigonometry."

  # It appears Elixir is able to compute these values
  # much more precisely than JS (whose delta is 1.0e-10)
  @tolerance 1.111e-15
  def tolerance, do: @tolerance

  ###
  #
  # TYPES
  #
  ###

  @typedoc """
    `position` encodes coordinates on the Sphere in the Geographic Coordinate System as
    tuples of the format `{:pos, latitude, longitude}`, i.e. `{:pos, φ, λ}`, where
    -π/2 ≤ φ ≤ π/2 and 0 ≤ λ ≤ 2π.
  """
  @type position :: {:pos, float, float}

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

  def distance(position_1, position_2)

  def distance({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon}) do
    2 *
      asin(
        sqrt(
          pow(sin((f1_lat - f2_lat) / 2), 2) +
            cos(f1_lat) * cos(f2_lat) * pow(sin((f1_lon - f2_lon) / 2), 2)
        )
      )
  end

  @doc """
    Returns the heading and distance from the first position to the second position.

    Used only for testing, so documentation is sparse.
  """

  @spec course(position, position) :: {:course, float, float}

  def course(position_1, position_2)

  def course({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon}) do
    d = distance({:pos, f1_lat, f1_lon}, {:pos, f2_lat, f2_lon})
    a_relative = acos((sin(f2_lat) - sin(f1_lat) * cos(d)) / (sin(d) * cos(f1_lat)))

    a = if sin(f2_lon - f1_lon) < 0, do: a_relative, else: 2 * pi() - a_relative

    {:course, a, d}
  end

  @doc """
    Calls `fun` `divisions`-1 times, once for each
    point spaced evenly between two points on the sphere, and reduces the
    `init_acc` into a final value.
  """
  @spec interpolate(
          any,
          GEOF.Sphere.divisions(),
          position,
          position,
          (any, integer, position -> any)
        ) :: any

  def interpolate(acc, divisions, position_1, position_2, fun)
      when is_integer(divisions) and divisions > 1 do
    Enum.reduce(1..(divisions - 1), acc, fn i, acc ->
      interpolate_step(acc, divisions, position_1, position_2, fun, i)
    end)
  end

  def interpolate(acc, _, _, _, _) do
    acc
  end

  defp interpolate_step(acc, d, position_1, position_2, fun, i) do
    {:pos, f1_lat, f1_lon} = position_1
    {:pos, f2_lat, f2_lon} = position_2

    f = i / d
    d = distance(position_1, position_2)

    a = sin((1 - f) * d) / sin(d)
    b = sin(f * d) / sin(d)

    x = a * cos(f1_lat) * cos(f1_lon) + b * cos(f2_lat) * cos(f2_lon)
    z = a * cos(f1_lat) * sin(f1_lon) + b * cos(f2_lat) * sin(f2_lon)
    y = a * sin(f1_lat) + b * sin(f2_lat)

    lat = atan2(y, sqrt(pow(x, 2) + pow(z, 2)))
    lon = atan2(z, x)

    fun.(acc, i, {:pos, lat, lon})
  end

  @doc """
    Computes the centroid of a polygon on the surface of the sphere defined
    by a list of `position`s.
  """

  @spec centroid(nonempty_list(position)) :: position | {:error, String.t()}

  def centroid(positions) do
    n = length(positions)

    x = Enum.reduce(positions, 0, fn {:pos, lat, lon}, sum -> sum + cos(lat) * cos(lon) / n end)
    z = Enum.reduce(positions, 0, fn {:pos, lat, lon}, sum -> sum + cos(lat) * sin(lon) / n end)
    y = Enum.reduce(positions, 0, fn {:pos, lat, _}, sum -> sum + sin(lat) / n end)

    r = sqrt(x * x + z * z + y * y)

    if abs(r) <= @tolerance do
      {:error, "Can't compute centroid from these points."}
    else
      {:pos, asin(y / r), atan2(z, x)}
    end
  end
end
