defmodule GEOFTest do
  use ExUnit.Case
  doctest GEOF

  test "greets the world" do
    assert GEOF.hello() == :world
  end
end
