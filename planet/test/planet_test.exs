defmodule PLANETTest do
  use ExUnit.Case
  doctest PLANET

  test "greets the world" do
    assert PLANET.hello() == :world
  end
end
