defmodule GEOF.Planet.SphereServerTest do
  use ExUnit.Case

  alias GEOF.Planet.Sphere
  alias GEOF.Planet.SphereServer

  doctest GEOF.Planet.SphereServer

  test "initializes" do
    d = 17
    id = make_ref()
    initial_count = :erlang.system_info(:process_count)

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    assert :erlang.system_info(:process_count) > initial_count
  end

  test "gets field data from panel children" do
    d = 17
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    assert MapSet.size(
             MapSet.difference(
               # All keys in Sphere by definition:
               Sphere.for_all_fields(MapSet.new(), d, &MapSet.put(&1, &2)),
               # All keys we get from SphereServer.get_all_data:
               MapSet.new(Map.keys(SphereServer.get_all_data(id)))
             )
           )
  end
end
