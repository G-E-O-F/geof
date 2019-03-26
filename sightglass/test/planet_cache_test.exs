defmodule GEOF.Sightglass.PlanetCacheTest do
  use ExUnit.Case

  alias GEOF.Sightglass.PlanetCache.Cache

  test "initializes" do
    assert {:ok, pcpid} = Cache.start_link(name: Cache)
    assert :ok = GenServer.stop(pcpid)
  end

  test "starts and stops a sphere" do
    assert {:ok, pcpid} = Cache.start_link(name: Cache)

    d = 17

    assert sphere_id = Cache.start_planet(divisions: d)

    assert :ok = Cache.end_planet(sphere_id)
    assert :not_found = Cache.end_planet(sphere_id)

    assert :ok = GenServer.stop(pcpid)
  end

  test "spheres time out" do
    assert {:ok, pcpid} = Cache.start_link(name: Cache)

    d = 3

    assert sphere_id = Cache.start_planet(divisions: d, timeout_duration: 100)

    assert field_data = Cache.get_planet_field_data(sphere_id)

    Process.sleep(500)

    assert :not_found = Cache.get_planet_field_data(sphere_id)

    assert :ok = GenServer.stop(pcpid)
  end
end
