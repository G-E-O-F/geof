defmodule PLANET.Geometry do
  import :math

  @moduledoc """
    PLANET.Geometry contains the mathematical functions necessary to
    compute the positional information for a Planet's Fields.
  """

  ### Attributes

  @doc "The arclength of an edge of an icosahedron."
  @l acos(sqrt(5) / 5)
  def l, do: @l

  @pi pi()

  @sections 0..4

  ### Types

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}
  @type field :: :north | :south | {:sxy, integer, integer, integer}
  @type sphere :: %{field => position}

  ### Functions

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
  @spec interpolate(any, integer, position, position, fun) :: {:ok}

  def interpolate(init_acc, divisions, pos_1, pos_2, into)
      when is_integer(divisions) and divisions > 1 do
    Enum.reduce(1..(divisions - 1), init_acc, fn i, acc ->
      interpolate_step(acc, divisions, pos_1, pos_2, into, i)
    end)
  end

  defp interpolate_step(acc, divisions, pos_1, pos_2, into, i) do
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

    into.(acc, i, {:pos, lat, lon})
  end

  @doc """
    Creates a Map between fields as <S,X,Y>|north|south and their centroids as the `sphere` type.
    The resolution of the sphere is determined by `divisions` supplied as the only argument.
  """
  @spec centroids(integer) :: sphere

  def centroids(divisions) when is_integer(divisions) and divisions > 1 do
    d = divisions
    max_x = 2 * d - 1

    # Initialize the result map with positions for polar fields
    centroids = %{
      north: {:pos, @pi / 2, 0.0},
      south: {:pos, @pi / -2, 0.0}
    }

    # Set positions for tropical fields
    for_sections(
      centroids,
      fn sphere, s ->
        set_position(
          sphere,
          {:sxy, s, d - 1, 0},
          {:pos, @pi / 2 - @l, s * 2 / 5 * @pi}
        )
        |> set_position(
          {:sxy, s, max_x, 0},
          {:pos, @pi / -2 + @l, s * 2 / 5 * @pi + @pi / 5}
        )
      end
    )
    # Set positions for fields between polar fields and tropical fields
    |> for_sections(fn sphere, s ->
      p = rem(s + 4, 5)

      snP = Map.get(sphere, :north)
      ssP = Map.get(sphere, :south)
      cnT = Map.get(sphere, {:sxy, s, d - 1, 0})
      pnT = Map.get(sphere, {:sxy, p, d - 1, 0})
      csT = Map.get(sphere, {:sxy, s, max_x, 0})
      psT = Map.get(sphere, {:sxy, p, max_x, 0})

      ## Set position for fields...

      # ...from north pole to current north tropical pentagon

      interpolate(
        sphere,
        d,
        snP,
        cnT,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, i - 1, 0}, position)
        end
      )

      # ...from current north tropical pentagon to previous north tropical pentagon

      |> interpolate(
        d,
        cnT,
        pnT,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, d - 1 - i, i}, position)
        end
      )

      # ...from current north tropical pentagon to previous south tropical pentagon

      |> interpolate(
        d,
        cnT,
        psT,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, d - 1, i}, position)
        end
      )

      # ...from current north tropical pentagon to current south tropical pentagon

      |> interpolate(
        d,
        cnT,
        csT,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, d - 1 + i, 0}, position)
        end
      )

      # ...from current south tropical pentagon to previous south tropical pentagon

      |> interpolate(
        d,
        csT,
        psT,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, max_x - i, i}, position)
        end
      )

      # ...from current south tropical pentagon to south pole

      |> interpolate(
        d,
        csT,
        ssP,
        fn sphere, i, position ->
          set_position(sphere, {:sxy, s, max_x, i}, position)
        end
      )
    end)
  end

  defp set_position(sphere, {:sxy, s, x, y}, {:pos, lat, lon}) do
    Map.put(sphere, {:sxy, s, x, y}, {:pos, lat, lon})
  end

  defp for_sections(sphere, each) do
    Enum.reduce(
      @sections,
      sphere,
      fn s, sphere ->
        each.(sphere, s)
      end
    )
  end
end
