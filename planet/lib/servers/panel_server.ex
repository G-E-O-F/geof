defmodule GEOF.Planet.PanelServer do
  @moduledoc """
    Hosts per-Field compute frames for a set of Fields in a Panel, a contiguous subset of a Sphere's Fields.
  """

  use GenServer

  alias GEOF.Planet.{
    Field,
    Registry,
    SphereServer
  }

  ###
  #
  # API
  #
  ###

  @spec start_link(SphereServer.sphere(), SphereServer.panel_index()) :: GenServer.on_start()

  def start_link(sphere, panel_index) do
    GenServer.start_link(__MODULE__, [sphere, panel_index],
      name: Registry.panel_via_reg(sphere.id, panel_index)
    )
  end

  # `get_state` is for testing purposes only

  def get_state(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_state)
  end

  @doc "Gets the data in each Field managed by this Panel"

  @spec get_all_field_data(SphereServer.sphere_id(), SphereServer.panel_index()) ::
          SphereServer.fields_data()

  def get_all_field_data(sphere_id, panel_index) do
    GenServer.call(Registry.panel_via_reg(sphere_id, panel_index), :get_all_field_data)
  end

  @doc "Starts a computation frame on this Panel. The PanelServer will send `__ready_to_commit_frame__` to its parent SphereServer when the frame is finished."

  @spec start_frame(
          SphereServer.sphere_id(),
          SphereServer.panel_index(),
          SphereServer.fn_ref(),
          any
        ) :: :ok

  def start_frame(sphere_id, panel_index, per_field, sphere_data) do
    GenServer.cast(
      Registry.panel_via_reg(sphere_id, panel_index),
      {:start_frame, per_field, sphere_data}
    )
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
    fields = sphere.fields_at_panels[panel_index]
    adjacent_fields = init_adjacent_fields(sphere, panel_index)

    {:ok,
     %{
       id: {sphere.id, panel_index},
       divisions: sphere.divisions,
       fields: fields,
       field_data: init_field_data(fields),
       adjacent_fields: adjacent_fields,
       n_adjacent_fields: n_adjacent_fields(adjacent_fields),
       sphere_data: nil,
       frame_fun: nil
     }}
  end

  @spec init_field_data(MapSet.t(Field.index())) :: SphereServer.fields_data()

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

  @impl true
  def handle_call(:__commit_frame__, _from, state) do
    state =
      Map.merge(state, %{
        frame_fun: nil,
        field_data: state.__current_frame__
      })

    state = Map.delete(state, :__current_frame__)
    {:reply, :ok, state}
  end

  ###
  # Adjacent field computation
  ###

  @doc """
    Creates a `fields_at_panels` mapping panel indexes to the fields belonging to those
    panels which are adjacent to _this_ panel. Used to share relevant field data between processes.
  """

  @spec init_adjacent_fields(SphereServer.sphere(), SphereServer.panel_index()) ::
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
              &MapSet.put(&1, foreign_adjacent_field_index)
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

  defp n_adjacent_fields(adjacent_fields) do
    Enum.reduce(adjacent_fields, 0, fn {_panel_index, fields_at_panel}, sum ->
      sum + MapSet.size(fields_at_panel)
    end)
  end

  ###
  # Frames
  ###

  @impl true
  def handle_cast({:start_frame, per_field, sphere_data}, state) do
    {sphere_id, panel_index} = state.id

    state = Map.put(state, :frame_fun, per_field)
    state = Map.put(state, :sphere_data, sphere_data)
    state = Map.put(state, :adjacent_field_data, Map.new())

    Enum.each(state.adjacent_fields, fn {adjacent_panel_index, fields} ->
      if adjacent_panel_index != panel_index and MapSet.size(fields) > 0 do
        GenServer.cast(
          Registry.panel_via_reg(sphere_id, adjacent_panel_index),
          {:__send_field_data__, panel_index, fields}
        )
      end
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:__send_field_data__, to_panel_index, fields}, state) do
    {sphere_id, _panel_index} = state.id

    Enum.each(fields, fn field_index ->
      if Map.has_key?(state.field_data, field_index) do
        GenServer.cast(
          Registry.panel_via_reg(sphere_id, to_panel_index),
          {:__receive_field_data__, field_index, state.field_data[field_index]}
        )
      end
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:__receive_field_data__, field_index, data_for_field}, state) do
    # store field_data in a cache of data for adjacent fields
    state =
      update_in(
        state.adjacent_field_data,
        &Map.put(&1, field_index, data_for_field)
      )

    # evaluate if we're ready to begin iterating
    if ready_to_populate_frame?(state) do
      GenServer.cast(self(), :__populate_frame__)
    end

    {:noreply, state}
  end

  @impl true
  def handle_cast(:__populate_frame__, state) do
    {sphere_id, panel_index} = state.id
    {module, function_name} = state.frame_fun

    state =
      Map.put(
        state,
        :__current_frame__,
        Enum.reduce(state.fields, %{}, fn field_index, current_frame ->
          Map.put(
            current_frame,
            field_index,
            apply(
              module,
              function_name,
              [
                {field_index, Map.get(state.field_data, field_index)},
                get_adjacents_for_apply(state, field_index),
                state.sphere_data
              ]
            )
          )
        end)
      )

    GenServer.cast(Registry.sphere_via_reg(sphere_id), {:__ready_to_commit_frame__, panel_index})

    {:noreply, state}
  end

  defp ready_to_populate_frame?(state) do
    map_size(state.adjacent_field_data) >= state.n_adjacent_fields
  end

  defp get_adjacents_for_apply(state, field_index) do
    {_sphere_id, panel_index} = state.id

    Map.new(
      Field.adjacents(field_index, state.divisions),
      fn {dir, adjacent_field_index} ->
        cond do
          Map.has_key?(state.field_data, adjacent_field_index) ->
            {dir, {adjacent_field_index, state.field_data[adjacent_field_index]}}

          Map.has_key?(state.adjacent_field_data, adjacent_field_index) ->
            {dir, {adjacent_field_index, state.adjacent_field_data[adjacent_field_index]}}

          true ->
            exit(
              "Field data logistical error: data for Field #{
                Field.index_to_string(adjacent_field_index)
              } not available for panel {ref, #{panel_index}}}"
            )
        end
      end
    )
  end
end
