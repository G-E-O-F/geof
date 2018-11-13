defmodule GEOF.Planet.PanelServer do
  use GenServer

  alias GEOF.Planet.Field
  alias GEOF.Planet.Registry
  alias GEOF.Planet.SphereServer

  ###
  #
  # Types
  #
  ###

  @type panel_index :: integer

  ###
  #
  # API
  #
  ###

  @spec start_link(SphereServer.sphere(), panel_index) :: GenServer.on_start()

  def start_link(sphere, panel_index) do
    GenServer.start_link(__MODULE__, [sphere, panel_index],
      name: Registry.panel_via_reg(sphere.id, panel_index)
    )
  end

  # `get_state` is for testing purposes only

  def get_state(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_state)
  end

  @spec get_all_field_data(SphereServer.sphere_id(), panel_index) :: SphereServer.sphere_data()

  def get_all_field_data(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_all_field_data)
  end

  @spec start_frame(SphereServer.sphere_id(), panel_index, SphereServer.fn_ref()) :: :ok

  def start_frame(sphere_id, panel_index, per_field) do
    GenServer.cast(
      Registry.panel_via_reg(sphere_id, panel_index),
      {:start_frame, per_field}
    )
  end

  @spec request_field_data(SphereServer.sphere_id(), panel_index, MapSet.t(Field.index())) :: :ok

  def request_field_data(_sphere_id, _panel_index, _adjacent_fields) do
    nil
  end

  ###
  #
  # Server
  #
  ###

  ###
  # Utility
  ###

  @impl true
  def init([sphere, panel_index]) do
    {:ok,
     %{
       id: {sphere.id, panel_index},
       parent_sphere: sphere.id,
       field_data: init_field_data(sphere.fields_at_panels[panel_index]),
       adjacent_fields: init_adjacent_fields(sphere, panel_index),
       in_frame: false
     }}
  end

  @spec init_field_data(MapSet.t(Field.index())) :: SphereServer.sphere_data()

  defp init_field_data(field_set) do
    Enum.reduce(field_set, %{}, &Map.put(&2, &1, nil))
  end

  @impl true
  def handle_call(:get_all_field_data, _from, state) do
    {:reply, state.field_data, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  ###
  # Adjacent field computation
  ###

  # @doc """
  #  Creates a `fields_at_panels` mapping panel indexes to the fields belonging to those
  #  panels which are adjacent to _this_ panel. Used to share relevant field data between processes.
  # """

  @spec init_adjacent_fields(SphereServer.sphere(), panel_index) ::
          SphereServer.fields_at_panels()

  defp init_adjacent_fields(sphere, panel_index) do
    panel_field_set = sphere.fields_at_panels[panel_index]

    Enum.reduce(
      panel_field_set,
      init_adjacent_fields(Map.keys(sphere.fields_at_panels)),
      fn field_index, adjacent_fields_at_panels ->
        Stream.reject(
          Field.adjacents(field_index, sphere.divisions),
          fn {_direction, adjacent_field_index} ->
            adjacent_field_index == nil or MapSet.member?(panel_field_set, adjacent_field_index)
          end
        )
        |> Enum.reduce(
          adjacent_fields_at_panels,
          fn {_direction, foreign_adjacent_field_index}, adjacent_fields_at_panels ->
            update_in(
              adjacent_fields_at_panels[
                panel_for_field(sphere.fields_at_panels, foreign_adjacent_field_index)
              ],
              &MapSet.put(&1, field_index)
            )
          end
        )
      end
    )
  end

  defp panel_for_field(fields_at_panels, field_index) do
    {panel_index, _field_set} =
      Enum.find(fields_at_panels, fn {_panel_index, field_set} ->
        MapSet.member?(field_set, field_index)
      end)

    panel_index
  end

  defp init_adjacent_fields(panel_indexes) do
    Enum.reduce(panel_indexes, %{}, fn panel_index, adjacent_fields_at_panels ->
      Map.put(adjacent_fields_at_panels, panel_index, MapSet.new())
    end)
  end

  ###
  # Frames
  ###

  @impl true
  def handle_cast({:start_frame, {module_name, function_name}}, state) do
    # todo: implement
    # …should probably use `apply` for each field somewhere, like so:
    #       apply(
    #         String.to_existing_atom("Elixir.#{module_name}"),
    #         func_name,
    #         [field_data, adjacent_fields_data_for_field]
    #       )
    {:noreply, Map.put(state, :in_frame, true)}
  end
end
