defmodule GEOF.Planet.Geometry.FieldCentroids do
  import :math
  import GEOF.Planet.Sphere
  import GEOF.Planet.Geometry

  @moduledoc """
    Functions for computing the positions of the centroids of
    each Field on a Sphere.
  """

  ###
  #
  # ATTRIBUTES
  #
  ###

  @doc "The arclength of an edge of an icosahedron."
  @l acos(sqrt(5) / 5)
  def l, do: @l

  ###
  #
  # TYPES
  #
  ###

  @type centroid_sphere :: %{GEOF.Planet.Field.index() => GEOF.Planet.Geometry.position()}

  ###
  #
  # FUNCTIONS
  #
  ###

  # Note: `divisions` is abbreviated as `d` in private functions.

  ##
  # Utility functions
  ##

  defp set_position(sphere, {:sxy, s, x, y}, {:pos, lat, lon}) do
    Map.put(sphere, {:sxy, s, x, y}, {:pos, lat, lon})
  end

  ##
  #
  # Centroid sphere computation
  #
  ##

  @doc """
    Creates a Map between fields as <S,X,Y>|north|south and their centroids as the `sphere` type. The resolution of the sphere is determined by `divisions` supplied as the only argument.
  """
  @spec field_centroids(integer) :: centroid_sphere

  def field_centroids(divisions) when is_integer(divisions) and divisions > 0 do
    d = divisions
    max_x = 2 * d - 1

    for_sections(
      # Initialize the map with positions for polar fields
      %{
        north: {:pos, pi() / 2, 0.0},
        south: {:pos, pi() / -2, 0.0}
      },
      # Set positions for the 2 tropical fields per section
      fn sphere, s ->
        set_position(
          sphere,
          {:sxy, s, d - 1, 0},
          {:pos, pi() / 2 - @l, s * 2 / 5 * pi()}
        )
        |> set_position(
          {:sxy, s, max_x, 0},
          {:pos, pi() / -2 + @l, s * 2 / 5 * pi() + pi() / 5}
        )
      end
    )
    # Set positions for fields between polar fields and tropical fields (d > 1)
    |> centroids_at_edge_fields(d)
    # Set positions for all other fields (d > 2)
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
    f3_index = Map.get(GEOF.Planet.Field.adjacents({:sxy, s, x, d - 1}, d), :sw)
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
