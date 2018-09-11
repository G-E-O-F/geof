defmodule GEOF.Planet.FieldServerTestBattery do
  def iterator(state, adjacent_states) do
    {:sxy, s, x, y} = Map.get(state, :id)
    s + x + y + length(adjacent_states)
  end
end

defmodule GEOF.Planet.FieldServerTest do
  use ExUnit.Case

  alias GEOF.Planet.FieldServer

  doctest GEOF.Planet.FieldServer

  test "initializes" do
    d = 2
    index = {:sxy, 1, 1, 1}
    sphere_id = make_ref()

    assert {:ok, fspid} =
             FieldServer.start_link(sphere_id, index, GEOF.Planet.Field.adjacents(index, d))

    assert state = FieldServer.get_state(sphere_id, index)

    assert Map.get(state, :sphere) == sphere_id
    assert Map.get(state, :id) == index
    assert :ok = GenServer.stop(fspid)
  end

  test "iterates" do
    d = 2
    index = {:sxy, 2, 2, 1}
    sphere_id = make_ref()

    {:ok, fsspid} = GEOF.Planet.FieldSupervisor.start_link(d, sphere_id)

    FieldServer.iterate(sphere_id, index, "GEOF.Planet.FieldServerTestBattery", :iterator)

    state = FieldServer.get_state(sphere_id, index)
    Process.sleep(100)

    assert Map.get(state, :data) == nil
    assert Map.get(state, :next) == 11

    FieldServer.finish_iteration(sphere_id, index)
    Process.sleep(100)
    final_state = FieldServer.get_state(sphere_id, index)
    Process.sleep(100)

    assert Map.get(final_state, :data) == 11
    refute Map.get(final_state, :next)

    :ok = GenServer.stop(fsspid)
  end
end
