defmodule GEOF.Planet.FieldTest do
  use ExUnit.Case

  import GEOF.Planet.Field

  doctest GEOF.Planet.Field

  test "links northern polar field correctly" do
    d = 1
    assert adjacents(:north, d).nw == {:sxy, 0, 0, 0}
    assert adjacents(:north, d).w == {:sxy, 1, 0, 0}
    assert adjacents(:north, d).sw == {:sxy, 2, 0, 0}
    assert adjacents(:north, d).se == {:sxy, 3, 0, 0}
    assert adjacents(:north, d).e == {:sxy, 4, 0, 0}
    assert adjacents(:north, d).ne == nil
  end

  test "links southern polar field correctly" do
    d = 3
    dy = d
    dx = 2 * d

    assert adjacents(:south, d).nw == {:sxy, 0, dx - 1, dy - 1}
    assert adjacents(:south, d).w == {:sxy, 1, dx - 1, dy - 1}
    assert adjacents(:south, d).sw == {:sxy, 2, dx - 1, dy - 1}
    assert adjacents(:south, d).se == {:sxy, 3, dx - 1, dy - 1}
    assert adjacents(:south, d).e == {:sxy, 4, dx - 1, dy - 1}
    assert adjacents(:south, d).ne == nil
  end

  test "links the northern tropical fields correctly" do
    d = 1
    index = {:sxy, 0, 0, 0}

    assert adjacents(index, d).nw == :north
    assert adjacents(index, d).w == {:sxy, 4, 0, 0}
    assert adjacents(index, d).sw == {:sxy, 4, 1, 0}
    assert adjacents(index, d).se == {:sxy, 0, 1, 0}
    assert adjacents(index, d).e == {:sxy, 1, 0, 0}
    assert adjacents(index, d).ne == nil
  end

  test "links the southern tropical fields correctly" do
    d = 1
    index = {:sxy, 0, 1, 0}

    assert adjacents(index, d).nw == {:sxy, 0, 0, 0}
    assert adjacents(index, d).w == {:sxy, 4, 1, 0}
    assert adjacents(index, d).sw == :south
    assert adjacents(index, d).se == {:sxy, 1, 1, 0}
    assert adjacents(index, d).e == {:sxy, 1, 0, 0}
    assert adjacents(index, d).ne == nil
  end

  test "links fields on the north-northeastern edge" do
    d = 3
    index = {:sxy, 0, 0, 0}

    assert adjacents(index, d).nw == :north
    assert adjacents(index, d).w == {:sxy, 4, 0, 0}
    assert adjacents(index, d).sw == {:sxy, 0, 0, 1}
    assert adjacents(index, d).se == {:sxy, 0, 1, 0}
    assert adjacents(index, d).e == {:sxy, 1, 0, 1}
    assert adjacents(index, d).ne == {:sxy, 1, 0, 0}
  end

  test "links fields on the east-northeastern edge" do
    d = 3
    index = {:sxy, 0, d, 0}

    assert adjacents(index, d).nw == {:sxy, 0, d - 1, 0}
    assert adjacents(index, d).w == {:sxy, 0, d - 1, 1}
    assert adjacents(index, d).sw == {:sxy, 0, d, 1}
    assert adjacents(index, d).se == {:sxy, 0, d + 1, 0}
    assert adjacents(index, d).e == {:sxy, 1, 1, d - 1}
    assert adjacents(index, d).ne == {:sxy, 1, 0, d - 1}
  end

  test "links fields on the southeastern edge" do
    d = 3
    dy = d
    dx = d * 2
    index = {:sxy, 0, dx - 1, 1}

    assert adjacents(index, d).nw == {:sxy, 0, dx - 2, 1}
    assert adjacents(index, d).w == {:sxy, 0, dx - 2, 2}
    assert adjacents(index, d).sw == {:sxy, 0, dx - 1, 2}
    assert adjacents(index, d).se == {:sxy, 1, dx / 2 + 1, dy - 1}
    assert adjacents(index, d).e == {:sxy, 1, dx / 2, dy - 1}
    assert adjacents(index, d).ne == {:sxy, 0, dx - 1, 0}
  end

  test "links internal fields" do
    d = 3
    index = {:sxy, 0, d, 1}

    assert adjacents(index, d).nw == {:sxy, 0, d - 1, 1}
    assert adjacents(index, d).w == {:sxy, 0, d - 1, 2}
    assert adjacents(index, d).sw == {:sxy, 0, d, 2}
    assert adjacents(index, d).se == {:sxy, 0, d + 1, 1}
    assert adjacents(index, d).e == {:sxy, 0, d + 1, 0}
    assert adjacents(index, d).ne == {:sxy, 0, d, 0}
  end
end
