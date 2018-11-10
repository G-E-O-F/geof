# defmodule GEOF.Planet.FieldServerTestBattery do
#  def iterator(state, adjacent_states) do
#    {:sxy, s, x, y} = Map.get(state, :id)
#    s + x + y + length(adjacent_states)
#  end
# end

defmodule GEOF.Planet.PanelServerTest do
  use ExUnit.Case

  alias GEOF.Planet.PanelServer

  doctest GEOF.Planet.PanelServer

  test "initializes" do
    sphere = %{
      id: make_ref()
    }

    index = 1

    field_set = MapSet.new()
    field_set = MapSet.put(field_set, {:sxy, 1, 1, 1})

    assert {:ok, pspid} = PanelServer.start_link(sphere, index, field_set)

    Process.sleep(120)

    assert state = PanelServer.get_state(sphere.id, index)

    assert Map.get(state, :id) == {sphere.id, index}
    assert :ok = GenServer.stop(pspid)
  end

  test "gets panel data" do
    sphere = %{
      id: make_ref()
    }

    index = 1
    key = {:sxy, 3, 1, 7}

    field_set = MapSet.new()
    field_set = MapSet.put(field_set, key)

    assert {:ok, pspid} = PanelServer.start_link(sphere, index, field_set)

    Process.sleep(120)

    assert data = PanelServer.get_all_data(sphere.id, index)

    assert Map.keys(data) == [key]
    assert :ok = GenServer.stop(pspid)
  end

  #  test "iterates" do
  #    d = 2
  #    index = {:sxy, 2, 2, 1}
  #    sphere_id = make_ref()
  #
  #    {:ok, fsspid} = GEOF.Planet.FieldSupervisor.start_link(d, sphere_id)
  #
  #    FieldServer.iterate(sphere_id, index, "GEOF.Planet.FieldServerTestBattery", :iterator)
  #
  #    state = FieldServer.get_state(sphere_id, index)
  #    Process.sleep(100)
  #
  #    assert Map.get(state, :data) == nil
  #    assert Map.get(state, :next) == 11
  #
  #    FieldServer.finish_iteration(sphere_id, index)
  #    Process.sleep(100)
  #    final_state = FieldServer.get_state(sphere_id, index)
  #    Process.sleep(100)
  #
  #    assert Map.get(final_state, :data) == 11
  #    refute Map.get(final_state, :next)
  #
  #    :ok = GenServer.stop(fsspid)
  #  end
end
