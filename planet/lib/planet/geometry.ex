defmodule PLANET.Geometry do
  import :math

  @moduledoc """
    PLANET.Geometry contains the mathematical functions necessary to
    compute the positional information for a Planet's Fields.
  """

  # Attributes

  @doc "The arclength of an edge of an icosahedron."
  @l acos(sqrt(5) / 5)
  def l, do: @l

  # Types

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}

  # Functions

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

  @doc """
    Calls the `into` callback function `divisions`-1 times, once for each
    point spaced evenly between two points on the sphere, and reduces the
    `init_acc` into a final value.
  """
  @spec interpolate(position, position, number, fun, any) :: {:ok}

  def interpolate(pos_1, pos_2, divisions, into, init_acc) do
    Enum.reduce(1..(divisions - 1), init_acc, fn i, acc ->
      interpolate_step(pos_1, pos_2, i, divisions, into, acc)
    end)
  end

  defp interpolate_step(pos_1, pos_2, i, divisions, into, acc) do
    {:pos, f1_lat, f1_lon} = pos_1
    {:pos, f2_lat, f2_lon} = pos_2

    f = i / divisions
    d = distance(pos_1, pos_2)

    a = sin((1 - f) * d) / sin(d)
    b = sin(f * d) / sin(d)

    x = a * cos(f1_lat) * cos(f1_lon) + b * cos(f2_lat) * cos(f2_lon)
    z = a * cos(f1_lat) * sin(f1_lon) + b * cos(f2_lat) * sin(f2_lon)
    y = a * sin(f1_lat) + b * sin(f2_lat)

    lat = atan2(y, sqrt(pow(x, 2) + pow(z, 2)))
    lon = atan2(z, x)

    into.(i, {:pos, lat, lon}, acc)
  end
end
