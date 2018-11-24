defmodule GEOF.Planet.PanelServerTest do
  use ExUnit.Case

  alias GEOF.Planet.PanelServer
  alias GEOF.Planet.SphereServer

  doctest GEOF.Planet.PanelServer

  test "initializes" do
    sphere = SphereServer.init_sphere(10, make_ref())

    index = 1

    assert {:ok, pspid} = PanelServer.start_link(sphere, index)

    Process.sleep(120)

    assert state = PanelServer.get_state(sphere.id, index)

    assert state.id == {sphere.id, index}

    assert many_adj_panels =
             Enum.reduce(
               state.adjacent_fields,
               0,
               fn {_panel_index, adjacent_fields}, acc ->
                 if MapSet.size(adjacent_fields) > 2, do: acc + 1, else: acc
               end
             )

    assert few_adj_panels =
             Enum.reduce(
               state.adjacent_fields,
               0,
               fn {_panel_index, adjacent_fields}, acc ->
                 size = MapSet.size(adjacent_fields)
                 if size > 0 and size <= 2, do: acc + 1, else: acc
               end
             )

    # The panels are triangular, so the bulk of the Fields should belong to the 3
    # panels that share an edge with this panel.
    assert many_adj_panels == 3
    # Sometimes there's a few adjacent Fields belonging to panels completely
    # opposite this panel's vertices.
    assert few_adj_panels <= 3
    # This panel shouldn't register any of its own Fields as adjacent.
    assert MapSet.size(state.adjacent_fields[index]) == 0

    assert :ok = GenServer.stop(pspid)
  end

  test "gets panel data" do
    sphere = SphereServer.init_sphere(10, make_ref())

    index = 2

    assert {:ok, pspid} = PanelServer.start_link(sphere, index)

    Process.sleep(120)

    assert data = PanelServer.get_all_field_data(sphere.id, index)

    assert length(Map.keys(data)) > 1
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
