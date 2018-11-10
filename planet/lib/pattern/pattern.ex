defmodule GEOF.Planet.Pattern do
  import GEOF.Planet.Sphere

  @moduledoc """
    Functions for producing colors across the sphere model.
  """

  @type color :: {:rgb, integer, integer, integer}
  @type frame :: %{GEOF.Planet.Field.index() => color}

  @highlight_icosahedron_c1 {:rgb, 228, 234, 192}
  @highlight_icosahedron_c2 {:rgb, 166, 206, 146}

  def highlight_icosahedron_on_field(:north, _), do: @highlight_icosahedron_c2
  def highlight_icosahedron_on_field(:south, _), do: @highlight_icosahedron_c2

  def highlight_icosahedron_on_field({:sxy, _s, x, y}, d) do
    cond do
      rem(x + y + 1, d) == 0 or rem(x + 1, d) == 0 or y == 0 ->
        @highlight_icosahedron_c2

      true ->
        @highlight_icosahedron_c1
    end
  end

  def highlight_icosahedron(divisions) do
    for_all_fields(%{}, divisions, fn acc, index ->
      Map.put(acc, index, highlight_icosahedron_on_field(index, divisions))
    end)
  end

  @tetrahedron_colors %{
    0 => {:rgb, 247, 230, 197},
    1 => {:rgb, 82, 131, 130},
    2 => {:rgb, 197, 81, 26},
    3 => {:rgb, 59, 51, 34},
    nil => {:rgb, 23, 20, 18}
  }

  def tetrahedron(divisions) do
    centroids = GEOF.Planet.Geometry.FieldCentroids.field_centroids(divisions)

    for_all_fields(%{}, divisions, fn acc, index ->
      Map.put(acc, index, tetrahedron(centroids, index))
    end)
  end

  def tetrahedron(centroids, index) do
    Map.get(
      @tetrahedron_colors,
      GEOF.Shapes.face_of_4_hedron(Map.get(centroids, index))
    )
  end

  @octahedron_colors %{
    0 => {:rgb, 247, 230, 197},
    1 => {:rgb, 82, 131, 130},
    2 => {:rgb, 164, 52, 93},
    3 => {:rgb, 59, 51, 34},
    4 => {:rgb, 4, 79, 103},
    5 => {:rgb, 140, 156, 118},
    6 => {:rgb, 197, 81, 26},
    7 => {:rgb, 219, 90, 107},
    nil => {:rgb, 23, 20, 18}
  }

  def octahedron(divisions) do
    centroids = GEOF.Planet.Geometry.FieldCentroids.field_centroids(divisions)

    for_all_fields(%{}, divisions, fn acc, index ->
      Map.put(acc, index, octahedron(centroids, index))
    end)
  end

  def octahedron(centroids, index) do
    Map.get(
      @octahedron_colors,
      GEOF.Shapes.face_of_8_hedron(Map.get(centroids, index))
    )
  end
end
