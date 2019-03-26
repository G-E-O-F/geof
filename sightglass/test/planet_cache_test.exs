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

    assert sphere_id =
             Cache.start_planet(divisions: d, timeout_duration: 500, reporter_process: self())

    assert_receive {:terminated, sphere_id}, 10000

    assert :ok = GenServer.stop(pcpid)
  end
end
