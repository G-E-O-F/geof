defmodule PLANET.PlanetTest do
  use ExUnit.Case
  doctest PLANET.Planet

  test "greets the world" do
    assert PLANET.Planet.hello() == :world
  end
end
