defmodule GEOF.Planet.Field do
  @moduledoc """
    Functions for handling an individual Field on a Planet.
  """

  alias GEOF.Planet.Sphere

  @typedoc """
    A Field's index uniquely identifies it on a Sphere and it's used to identify its position
    and which Fields are adjacent.

    If the Field is not one of the poles, it's defined by its SXY coordinates, where S is
    the section `0..4`, X is `0..divisions * 2`, Y is `0..divisions`.
  """
  @type index :: :north | :south | {:sxy, non_neg_integer, non_neg_integer, non_neg_integer}

  # Sections is the number of 2-dimensional arrays in the Sphere. It's always 5.
  @sections 5

  @doc """
    Determines the 1-dimensional integer index of a Field given its index
    and the Sphere's number of divisions.
  """

  @spec flatten_index(index, Sphere.divisions()) :: non_neg_integer

  def flatten_index(:north, _), do: 0

  def flatten_index(:south, _), do: 1

  def flatten_index(field_index, divisions)

  def flatten_index({:sxy, s, x, y}, d) do
    s * d * d * 2 + x * d + y + 2
  end

  @doc """
    Stringifies a Field index.
  """

  @spec index_to_string(index) :: String.t()

  def index_to_string(field_index)
  def index_to_string(:north), do: ":north"
  def index_to_string(:south), do: ":south"
  def index_to_string({:sxy, s, x, y}), do: "{:sxy, #{s}, #{x}, #{y}}}"

  @typedoc """
    Provides the indexes of Fields that are adjacent to this Field, organized by specific relative positions relevant to the way the Sphere is organized.

    For pentagonal fields, all located at a vertex of the icosahedron, no `ne` adjacent Field is defined.
  """

  @type adjacents_map ::
          %{
            nw: index,
            w: index,
            sw: index,
            se: index,
            e: index
          }
          | %{
              nw: index,
              w: index,
              sw: index,
              se: index,
              e: index,
              ne: index
            }

  @doc """
    Provides a map of indexes for a field's adjacent fields.
  """

  @spec is_pentagon(index, Sphere.divisions()) :: boolean

  def is_pentagon(field_index, divisions)
  def is_pentagon(:north, _), do: true
  def is_pentagon(:south, _), do: true
  def is_pentagon({:sxy, _s, x, y}, d), do: y == 0 and rem(x + 1, d) == 0

  @doc """
    Provides a map of indexes for a field's adjacent fields.
  """

  @spec adjacents(index, Sphere.divisions()) :: adjacents_map

  def adjacents(field_index, divisions)

  def adjacents(:north, _) do
    %{
      nw: {:sxy, 0, 0, 0},
      w: {:sxy, 1, 0, 0},
      sw: {:sxy, 2, 0, 0},
      se: {:sxy, 3, 0, 0},
      e: {:sxy, 4, 0, 0}
    }
  end

  def adjacents(:south, divisions) do
    max_x = divisions * 2 - 1
    max_y = divisions - 1

    %{
      nw: {:sxy, 0, max_x, max_y},
      w: {:sxy, 1, max_x, max_y},
      sw: {:sxy, 2, max_x, max_y},
      se: {:sxy, 3, max_x, max_y},
      e: {:sxy, 4, max_x, max_y}
    }
  end

  def adjacents({:sxy, s, x, y}, d) do
    max_x = d * 2 - 1
    max_y = d - 1

    next_s = rem(s + 1 + @sections, @sections)
    prev_s = rem(s - 1 + @sections, @sections)

    is_pentagon = is_pentagon({:sxy, s, x, y}, d)

    # northwestern adjacent (x--)
    adj_nw =
      cond do
        x > 0 -> {:sxy, s, x - 1, y}
        y == 0 -> :north
        true -> {:sxy, prev_s, y - 1, 0}
      end

    # western adjacent (x--, y++)
    adj_w =
      cond do
        # attach northwestern edge to previous north-northeastern edge
        x == 0 -> {:sxy, prev_s, y, 0}
        # attach southwestern edge to previous southeastern edge
        y == max_y and x > d -> {:sxy, prev_s, max_x, x - d}
        # attach southwestern edge to previous east-northeastern edge
        y == max_y -> {:sxy, prev_s, x + d - 1, 0}
        true -> {:sxy, s, x - 1, y + 1}
      end

    # southwestern adjacent (y++)
    adj_sw =
      cond do
        y < max_y -> {:sxy, s, x, y + 1}
        x == max_x and y == max_y -> :south
        # attach southwestern edge to previous southeastern edge
        x >= d -> {:sxy, prev_s, max_x, x - d + 1}
        # attach southwestern edge to previous east-northeastern edge
        true -> {:sxy, prev_s, x + d, 0}
      end

    # southeastern adjacent (x++)
    adj_se =
      cond do
        is_pentagon and x == d - 1 -> {:sxy, s, x + 1, 0}
        is_pentagon and x == max_x -> {:sxy, next_s, d, max_y}
        x == max_x -> {:sxy, next_s, y + d, max_y}
        true -> {:sxy, s, x + 1, y}
      end

    # eastern adjacent (x++, y--)
    adj_e =
      cond do
        is_pentagon and x == d - 1 -> {:sxy, next_s, 0, max_y}
        is_pentagon and x == max_x -> {:sxy, next_s, d - 1, max_y}
        x == max_x -> {:sxy, next_s, y + d - 1, max_y}
        # attach northeastern side to next northwestern edge
        y == 0 and x < d -> {:sxy, next_s, 0, x + 1}
        # attach northeastern side to next west-southwestern edge
        y == 0 -> {:sxy, next_s, x - d + 1, max_y}
        true -> {:sxy, s, x + 1, y - 1}
      end

    if is_pentagon do
      %{
        nw: adj_nw,
        w: adj_w,
        sw: adj_sw,
        se: adj_se,
        e: adj_e
      }
    else
      # northeastern adjacent (y--)
      adj_ne =
        cond do
          is_pentagon -> nil
          y > 0 -> {:sxy, s, x, y - 1}
          # attach northeastern side to next northwestern edge
          y == 0 and x < d -> {:sxy, next_s, 0, x}
          # attach northeastern side to next west-southwestern edge
          y == 0 -> {:sxy, next_s, x - d, max_y}
        end

      %{
        nw: adj_nw,
        w: adj_w,
        sw: adj_sw,
        se: adj_se,
        e: adj_e,
        ne: adj_ne
      }
    end
  end
end
