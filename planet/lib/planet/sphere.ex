defmodule PLANET.Sphere do
  @moduledoc """
  Basic utility functions for spherical Planet data.
  """

  @sections 0..4

  def for_sections(acc, each) do
    Enum.reduce(
      @sections,
      acc,
      fn s, acc ->
        each.(acc, s)
      end
    )
  end

  def for_columns(acc, divisions, each) do
    Enum.reduce(
      0..(divisions * 2 - 1),
      acc,
      fn x, acc ->
        each.(acc, x)
      end
    )
  end

  def for_rows(acc, divisions, each) do
    Enum.reduce(
      0..(divisions - 1),
      acc,
      fn y, acc ->
        each.(acc, y)
      end
    )
  end

  def for_all_fields(acc, divisions, each) do
    acc
    |> each.(:north)
    |> each.(:south)
    |> for_sections(fn acc, s ->
      for_columns(acc, divisions, fn acc, x ->
        for_rows(acc, divisions, fn acc, y ->
          each.(acc, {:sxy, s, x, y})
        end)
      end)
    end)
  end
end
