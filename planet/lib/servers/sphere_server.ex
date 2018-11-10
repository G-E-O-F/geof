defmodule GEOF.Planet.SphereServer do
  use GenServer

  import GEOF.Planet.Registry
  import GEOF.Planet.Geometry.FieldCentroids
  import GEOF.Planet.Geometry.InterfieldCentroids
  import GEOF.Planet.Sphere
  import GEOF.Shapes

  alias GEOF.Planet.PanelSupervisor
  alias GEOF.Planet.PanelServer

  # API

  def start_link(divisions, sphere_id) do
    GenServer.start_link(__MODULE__, [divisions, sphere_id], name: sphere_via_reg(sphere_id))
  end

  def get_all_data(sphere_id) do
    GenServer.call(sphere_via_reg(sphere_id), :get_all_data)
  end

  def start_frame(sphere_id, {module_name, function_name}) do
    per_field = {module_name, function_name}
    GenServer.cast(sphere_via_reg(sphere_id), {:start_frame, per_field})
  end

  # SERVER

  @impl true
  def init([divisions, sphere_id]) do
    field_centroids = field_centroids(divisions)
    interfield_centroids = interfield_centroids(field_centroids, divisions)

    sphere = %{
      id: sphere_id,
      divisions: divisions,
      field_centroids: field_centroids,
      interfield_centroids: interfield_centroids
    }

    sphere = Map.put(sphere, :field_sets, get_field_sets(sphere))

    {:ok, panel_supervisor} = PanelSupervisor.start_link(sphere)

    {:ok,
     %{
       sphere: sphere,
       panel_supervisor: panel_supervisor,
       in_frame: false
     }}
  end

  @impl true
  def handle_call(:get_all_data, _from, state) do
    {:reply,
     Enum.reduce(Map.keys(state.sphere.field_sets), %{}, fn panel_index, all_data ->
       panel_data = PanelServer.get_all_data(state.sphere.id, panel_index)

       Map.merge(
         all_data,
         panel_data
       )
     end), state}
  end

  @impl true
  def handle_cast({:start_frame, per_field}, state) do
    Enum.each(Map.keys(state.sphere.field_sets), fn panel_index ->
      PanelServer.start_frame(
        state.sphere.id,
        panel_index,
        per_field,
        # TODO: compute & maintain `adjacent_fields_data_for_panel` (atom is just placeholder)
        :adjacent_fields_data_for_panel
      )
    end)

    {:noreply, Map.put(state, :in_frame, true)}
  end

  # TODO: how does a frame end?

  # Computing Panels as sets of Fields

  defp get_field_sets(sphere) do
    threads = :erlang.system_info(:schedulers_online)

    cond do
      threads >= 8 -> get_field_sets(sphere, 8)
      threads > 0 -> get_field_sets(sphere, 4)
    end
  end

  defp get_field_sets(sphere, n) when n == 4 do
    for_all_fields(init_field_sets(n), sphere.divisions, fn field_sets, field_index ->
      panel_index_for_field = face_of_4_hedron(sphere.field_centroids[field_index])

      update_in(
        field_sets[panel_index_for_field],
        &MapSet.put(&1, field_index)
      )
    end)
  end

  defp get_field_sets(sphere, n) when n == 8 do
    for_all_fields(init_field_sets(n), sphere.divisions, fn field_sets, field_index ->
      panel_index_for_field = face_of_8_hedron(sphere.field_centroids[field_index])

      update_in(
        field_sets[panel_index_for_field],
        &MapSet.put(&1, field_index)
      )
    end)
  end

  defp init_field_sets(n) do
    Enum.reduce(0..(n - 1), %{}, fn panel_index, field_sets ->
      Map.put(field_sets, panel_index, MapSet.new())
    end)
  end
end
