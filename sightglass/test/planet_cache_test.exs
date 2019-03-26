defmodule GEOF.Sightglass.PlanetCacheTestBattery do
  def add_one_to_field({_field_index, field_data}, _adjacent_fields_with_data, _sphere_data) do
    if field_data == nil do
      1
    else
      field_data + 1
    end
  end
end

defmodule GEOF.Sightglass.PlanetCacheTest do
  use ExUnit.Case

  alias GEOF.Sightglass.PlanetCache.Cache
  alias GEOF.Planet.Sphere

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
             Cache.start_planet(
               divisions: d,
               timeout_duration: 500,
               requester: self()
             )

    assert field_data = Cache.get_planet_field_data(sphere_id)

    assert_receive {:terminated, sphere_id}, 5000

    assert :not_found = Cache.get_planet_field_data(sphere_id)

    assert :ok = GenServer.stop(pcpid)
  end

  test "runs compute frames" do
    assert {:ok, pcpid} = Cache.start_link(name: Cache)

    d = 5

    assert sphere_id =
             Cache.start_planet(
               divisions: d,
               requester: self()
             )

    all_fields_with_one = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 1))

    Cache.run_frame(sphere_id, {"GEOF.Sightglass.PlanetCacheTestBattery", "add_one_to_field"})

    assert_receive {:frame_complete, fields_data}, 5000

    assert fields_data == all_fields_with_one

    assert :ok = GenServer.stop(pcpid)
  end
end
