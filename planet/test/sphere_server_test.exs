defmodule GEOF.Planet.SphereServerTestBattery do
  alias GEOF.Planet.Field

  def add_one_to_field({_field_index, field_data}, _adjacent_fields_with_data, _sphere_data) do
    if field_data == nil do
      1
    else
      field_data + 1
    end
  end

  def confirm_link({field_index, _field_data}, adjacent_fields_with_data, _sphere_data) do
    # Assumes divisions is 8!
    adj = Field.adjacents(field_index, 8)

    adj ==
      Map.new(adjacent_fields_with_data, fn {dir, {adj_field_index, nil}} ->
        {dir, adj_field_index}
      end)
  end

  def confirm_sphere_data(_field_data, _adjacent_fields_with_data, sphere_data) do
    sphere_data + 2
  end
end

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
    assert :ok = GenServer.stop(sspid)
  end

  test "times out" do
    d = 11
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id, 100, self())

    assert field_data = SphereServer.get_all_field_data(id)

    assert_receive {:inactive, sphere_id}, 200

    assert sphere_id == id

    assert :ok = GenServer.stop(sspid)
  end

  test "gets field data from panel children" do
    d = 17
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    assert MapSet.size(
             MapSet.difference(
               # All keys in Sphere by definition:
               Sphere.for_all_fields(MapSet.new(), d, &MapSet.put(&1, &2)),
               # All keys we get from SphereServer.get_all_field_data:
               MapSet.new(Map.keys(SphereServer.get_all_field_data(id)))
             )
           ) == 0

    assert :ok = GenServer.stop(sspid)
  end

  test "gets basic geometry" do
    d = 9
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    assert %{:divisions => div, :field_centroids => f_c, :interfield_centroids => if_c} =
             SphereServer.get_basic_geometry(id)

    assert div == d

    assert :ok = GenServer.stop(sspid)
  end

  test "fields have access to global sphere data" do
    d = 8
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    all_fields_with_three = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 3))

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "confirm_sphere_data"},
      1,
      self()
    )

    assert_receive {:frame_complete, sphere_id}, 5000

    assert sphere_id == id

    assert SphereServer.get_all_field_data(id) == all_fields_with_three

    assert :ok = GenServer.stop(sspid)
  end

  test "iterates twice" do
    d = 8
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    all_fields_with_one = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 1))
    all_fields_with_two = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 2))

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "add_one_to_field"},
      nil,
      self()
    )

    assert_receive {:frame_complete, sphere_id}, 5000

    assert sphere_id == id

    assert SphereServer.get_all_field_data(id) == all_fields_with_one

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "add_one_to_field"},
      nil,
      self()
    )

    assert_receive {:frame_complete, sphere_id}, 5000

    assert sphere_id == id

    assert SphereServer.get_all_field_data(id) == all_fields_with_two

    assert :ok = GenServer.stop(sspid)
  end

  test "confirms adjacent panels are properly linked" do
    d = 8
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    all_fields_with_true = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, true))

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "confirm_link"},
      nil,
      self()
    )

    assert_receive {:frame_complete, sphere_id}, 5000

    assert sphere_id == id

    assert SphereServer.get_all_field_data(id) == all_fields_with_true

    assert :ok = GenServer.stop(sspid)
  end
end
