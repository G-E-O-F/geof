defmodule GEOF.Planet.Sphere do
  @moduledoc """
    Functions for working with a Planet's Sphere.
  """

  alias GEOF.Planet.Field

  @typedoc """
    `divisions` is a the number of times to divide each edge of the icosohedron that subdivides
    the Sphere's surface.

    It's essentially the Sphere's resolution. The number of Fields on the surface of a Sphere is
    equal to `10 * divisions * divisions + 2`.
  """

  @type divisions :: pos_integer

  @typedoc "Function called during iteration over all Fields of a Sphere"

  @type field_reducer :: (any, Field.index() -> any)

  @typedoc "Function called during SXY component iteration"

  @type sxy_reducer :: (any, integer -> any)

  @doc "Iterates through each Field of the Sphere."

  @spec for_all_fields(any, divisions, field_reducer) :: any

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

  @doc "Iterates through each section of the Sphere."

  @spec for_sections(any, sxy_reducer) :: any

  def for_sections(acc, each) do
    Enum.reduce(
      0..4,
      acc,
      fn s, acc ->
        each.(acc, s)
      end
    )
  end

  @doc "Iterates through each column at X of a Sphere's section."

  @spec for_columns(any, divisions, sxy_reducer) :: any

  def for_columns(acc, divisions, each) do
    Enum.reduce(
      0..(divisions * 2 - 1),
      acc,
      fn x, acc ->
        each.(acc, x)
      end
    )
  end

  @doc "Iterates through each row at Y of a Sphere's section."

  @spec for_rows(any, divisions, sxy_reducer) :: any

  def for_rows(acc, divisions, each) do
    Enum.reduce(
      0..(divisions - 1),
      acc,
      fn y, acc ->
        each.(acc, y)
      end
    )
  end
end
