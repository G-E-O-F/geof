defmodule PLANET.Geometry do
  import :math

  @moduledoc """
    PLANET.Geometry contains the mathematical functions necessary to
    compute the positional information for a Planet's Fields.
  """

  ###
  #
  # ATTRIBUTES
  #
  ###

  @doc "The arclength of an edge of an icosahedron."
  @l acos(sqrt(5) / 5)
  def l, do: @l

  @pi pi()

  @sections 0..4

  ###
  #
  # TYPES
  #
  ###

  @type position :: {:pos, float, float}
  @type course :: {:course, float, float}
  @type sphere :: %{PLANET.Field.index() => position}

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

  @doc """
    Calls the `into` callback function `divisions`-1 times, once for each
    point spaced evenly between two points on the sphere, and reduces the
    `init_acc` into a final value.
  """
  @spec interpolate(any, integer, position, position, fun) :: {:ok}

  def interpolate(init_acc, divisions, pos_1, pos_2, into)
      when is_integer(divisions) do
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

  ##
  # Utility functions
  ##

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

  defp for_columns(sphere, d, each) do
    Enum.reduce(
      0..(d * 2 - 1),
      sphere,
      fn x, sphere ->
        each.(sphere, x)
      end
    )
  end

  ##
  #
  # Centroid sphere computation
  #
  ##

  @doc """
    Creates a Map between fields as <S,X,Y>|north|south and their centroids as the `sphere` type.
    The resolution of the sphere is determined by `divisions` supplied as the only argument.
  """
  @spec centroids(integer) :: sphere

  def centroids(divisions) when is_integer(divisions) and divisions > 0 do
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
    |> centroids_at_edge_fields(d)
    |> centroids_between_edges(d)
  end

  ##
  # Centroids at edges
  ##

  defp centroids_at_edge_fields(sphere, d) when is_integer(d) and d > 1 do
    max_x = 2 * d - 1

    for_sections(sphere, fn sphere, s ->
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

  defp centroids_at_edge_fields(sphere, d) when is_integer(d) and d <= 1 do
    sphere
  end

  ##
  # Centroids between edges
  ##

  defp centroids_between_edges(sphere, d) when is_integer(d) and d > 2 do
    for_sections(sphere, fn sphere, s ->
      for_columns(sphere, d, fn sphere, x ->
        set_positions_between_edges(sphere, d, s, x)
      end)
    end)
  end

  defp centroids_between_edges(sphere, d) when is_integer(d) and d <= 2 do
    sphere
  end

  defp set_positions_between_edges(sphere, d, s, x) when rem(x + 1, d) > 0 do
    j = d - rem(x + 1, d)
    n1 = j - 1
    n2 = d - 1 - j
    f1 = Map.get(sphere, {:sxy, s, x, 0})
    f2 = Map.get(sphere, {:sxy, s, x, j})
    f3_index = Map.get(PLANET.Field.adjacents({:sxy, s, x, d - 1}, d), :sw)
    f3 = Map.get(sphere, f3_index)

    interpolate(
      sphere,
      n1 + 1,
      f1,
      f2,
      fn sphere, i, position ->
        set_position(sphere, {:sxy, s, x, i}, position)
      end
    )
    |> interpolate(
      n2 + 1,
      f2,
      f3,
      fn sphere, i, position ->
        set_position(sphere, {:sxy, s, x, i + j}, position)
      end
    )
  end

  defp set_positions_between_edges(sphere, _, _, _) do
    sphere
  end
end
