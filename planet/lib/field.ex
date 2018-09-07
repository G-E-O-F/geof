defmodule GEOF.Planet.Field do
  @moduledoc """
    Functions for handling an individual Field on a Planet.
  """

  @type index :: :north | :south | {:sxy, integer, integer, integer}

  @sections 5

  @doc "Provides a map of indices for a field's adjacent fields."
  def adjacents(:north, _) do
    %{
      nw: {:sxy, 0, 0, 0},
      w: {:sxy, 1, 0, 0},
      sw: {:sxy, 2, 0, 0},
      se: {:sxy, 3, 0, 0},
      e: {:sxy, 4, 0, 0},
      ne: nil
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
      e: {:sxy, 4, max_x, max_y},
      ne: nil
    }
  end

  def adjacents({:sxy, s, x, y}, divisions) do
    d = divisions
    max_x = divisions * 2 - 1
    max_y = divisions - 1

    next_s = rem(s + 1 + @sections, @sections)
    prev_s = rem(s - 1 + @sections, @sections)

    is_pentagon = y == 0 and rem(x + 1, d) == 0

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
