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

  @pi pi()

  # Types

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}
  @type field :: :north | :south | {:sxy, integer, integer, integer}
  @type sphere :: %{field => position}

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

  @doc """
    Creates a Map between fields as <S,X,Y>|north|south and their centroids as the `sphere` type.
    The resolution of the sphere is determined by `divisions` supplied as the only argument.
  """
  @spec centroids(number) :: sphere

  def centroids(divisions) do
    d = divisions
    max_x = 2 * d - 1

    # Initialize the result map with polar fields
    centroids = %{
      north: {:pos, @pi / 2, 0},
      south: {:pos, @pi / -2, 0}
    }

    # Determine position for tropical fields using only arithmetic.
    centroids =
      Enum.reduce(
        0..4,
        centroids,
        fn s, sphere ->
          set_on_sphere(
            sphere,
            s,
            d - 1,
            0,
            @pi / 2 - @l,
            s * 2 / 5 * @pi
          )
          |> set_on_sphere(
            s,
            max_x,
            0,
            @pi / -2 + @l,
            s * 2 / 5 * @pi + @pi / 5
          )
        end
      )
  end

  defp set_on_sphere(sphere, s, x, y, lat, lon) do
    Map.put(sphere, {:sxy, s, x, y}, {:pos, lat, lon})
  end
end
