defmodule GEOF.Planet.PanelServer do
  use GenServer
  import GEOF.Planet.Registry

  # API

  def start_link(sphere, panel_index, field_set) do
    GenServer.start_link(__MODULE__, [sphere, panel_index, field_set],
      name: panel_via_reg(sphere.id, panel_index)
    )
  end

  def get_all_data(sphere_id, panel_index) do
    GenServer.call(panel_via_reg(sphere_id, panel_index), :get_all_data)
  end

  def start_frame(sphere_id, panel_index, per_field, adjacent_fields_data_for_panel) do
    GenServer.cast(
      panel_via_reg(sphere_id, panel_index),
      {:start_frame, per_field, adjacent_fields_data_for_panel}
    )
  end

  # `get_state` is for testing purposes only
  def get_state(sphere_id, panel_index) do
    GenServer.call(panel_via_reg(sphere_id, panel_index), :get_state)
  end

  # SERVER

  @impl true
  def init([sphere, panel_index, field_set]) do
    {:ok,
     %{
       id: {sphere.id, panel_index},
       parent_sphere: sphere.id,
       field_data: Enum.reduce(field_set, %{}, &Map.put(&2, &1, nil))
     }}
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
    # TODO: implement
    # …should probably use `apply` for each field somewhere, like so:
    #       apply(
    #         String.to_existing_atom("Elixir.#{module_name}"),
    #         func_name,
    #         [field_data, adjacent_fields_data_for_field]
    #       )
    {:noreply, state}
  end
end
