defmodule GEOF.Planet.PanelServer do
  use GenServer

  alias GEOF.Planet.Field
  alias GEOF.Planet.Registry

  # API

  def start_link(sphere, panel_index) do
    GenServer.start_link(__MODULE__, [sphere, panel_index],
      name: Registry.panel_via_reg(sphere.id, panel_index)
    )
  end

  def get_all_data(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_all_data)
  end

  def start_frame(sphere_id, panel_index, per_field, adjacent_fields_data_for_panel) do
    GenServer.cast(
      Registry.panel_via_reg(sphere_id, panel_index),
      {:start_frame, per_field, adjacent_fields_data_for_panel}
    )
  end

  # `get_state` is for testing purposes only
  def get_state(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_state)
  end

  # SERVER

  @impl true
  def init([sphere, panel_index]) do
    {:ok,
     %{
       id: {sphere.id, panel_index},
       parent_sphere: sphere.id,
       field_data: Enum.reduce(sphere.field_sets[panel_index], %{}, &Map.put(&2, &1, nil)),
       adjacent_fields: get_adjacent_fields(sphere, panel_index)
     }}
  end

  # @doc """
  #  Creates a `map_of_fields_at_panels` mapping panel indexes to the fields belonging to those
  #  panels which are adjacent to _this_ panel. Used to share relevant field data between processes.
  # """

  @spec get_adjacent_fields(SphereServer.sphere(), integer) ::
          SphereServer.map_of_fields_at_panels()

  defp get_adjacent_fields(sphere, panel_index) do
    panel_field_set = sphere.field_sets[panel_index]

    Enum.reduce(
      panel_field_set,
      init_adjacent_fields(Map.keys(sphere.field_sets)),
      fn field_index, adjacent_field_sets ->
        Stream.reject(
          Field.adjacents(field_index, sphere.divisions),
          fn {_direction, adjacent_field_index} ->
            adjacent_field_index == nil or MapSet.member?(panel_field_set, adjacent_field_index)
          end
        )
        |> Enum.reduce(
          adjacent_field_sets,
          fn {_direction, foreign_adjacent_field_index}, adjacent_field_sets ->
            update_in(
              adjacent_field_sets[
                get_panel_index_for_field(sphere.field_sets, foreign_adjacent_field_index)
              ],
              &MapSet.put(&1, field_index)
            )
          end
        )
      end
    )
  end

  defp get_panel_index_for_field(field_sets, field_index) do
    {panel_index, _field_set} =
      Enum.find(field_sets, fn {_panel_index, field_set} ->
        MapSet.member?(field_set, field_index)
      end)

    panel_index
  end

  defp init_adjacent_fields(panel_indexes) do
    Enum.reduce(panel_indexes, %{}, fn panel_index, adjacent_field_sets ->
      Map.put(adjacent_field_sets, panel_index, MapSet.new())
    end)
  end

  @impl true
  def handle_call(:get_all_data, _from, state) do
    {:reply, state.field_data, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(
        {:start_frame, {module_name, function_name}, adjacent_fields_data_for_panel},
        state
      ) do
    # todo: implement
    # …should probably use `apply` for each field somewhere, like so:
    #       apply(
    #         String.to_existing_atom("Elixir.#{module_name}"),
    #         func_name,
    #         [field_data, adjacent_fields_data_for_field]
    #       )
    {:noreply, state}
  end
end
