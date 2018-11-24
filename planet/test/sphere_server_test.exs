defmodule GEOF.Planet.SphereServerTestBattery do
  alias GEOF.Planet.Field

  def add_one_to_field({_field_index, field_data}, _adjacent_fields_with_data) do
    if field_data == nil do
      1
    else
      field_data + 1
    end
  end

  def confirm_link({field_index, _field_data}, adjacent_fields_with_data) do
    # Assumes divisions is 8!
    adj = Field.adjacents(field_index, 8)

    adj ==
      Map.new(adjacent_fields_with_data, fn {dir, {adj_field_index, nil}} ->
        {dir, adj_field_index}
      end)
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

  test "iterates twice" do
    d = 8
    id = make_ref()

    assert {:ok, sspid} = SphereServer.start_link(d, id)

    all_fields_with_one = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 1))
    all_fields_with_two = Sphere.for_all_fields(Map.new(), d, &Map.put(&1, &2, 2))

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "add_one_to_field"},
      self()
    )

    assert_receive :frame_complete, 5000

    assert SphereServer.get_all_field_data(id) == all_fields_with_one

    SphereServer.start_frame(
      id,
      {"GEOF.Planet.SphereServerTestBattery", "add_one_to_field"},
      self()
    )

    assert_receive :frame_complete, 5000

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
      self()
    )

    assert_receive :frame_complete, 5000

    assert SphereServer.get_all_field_data(id) == all_fields_with_true

    assert :ok = GenServer.stop(sspid)
  end
end
