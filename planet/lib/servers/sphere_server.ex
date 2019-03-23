defmodule GEOF.Planet.SphereServer do
  @moduledoc """
    The main server for running computations over the Sphere.

    ## Naming conventions:

    In all servers for GEOF.Planet, the names `panel` and `field` are equivalent to `panel_index` and
    `field_index` respectively for the sake of brevity. The data belonging to a field is always
    `field_data`, and a group of such data is `fields_data`, whether it’s data for just part of
    the sphere or for the entire sphere.

    In the servers’ APIs, `get` is always a call, and `send` and `receive` are always casts.

    Atoms surrounded with double-underscores indicate messages and state keys that are intended
    only to be used by methods internal to `SphereServer` and `PanelServer`. Once an iteration is
    complete, no remaining messages or state keys should be present in the system.
  """

  use GenServer

  alias GEOF.Shapes

  alias GEOF.Planet.{
    Geometry.FieldCentroids,
    Geometry.InterfieldCentroids,
    PanelSupervisor,
    PanelServer,
    Registry,
    Sphere,
    Field
  }

  ###
  #
  # Types
  #
  ###

  @typedoc "A Sphere reference. Any number of Spheres could be running, so this is a `reference`."
  @type sphere_id :: reference

  @typedoc "A Panel index. Spheres will manage a limited number of Panels, so this is just a non-negative integer."
  @type panel_index :: non_neg_integer

  @typedoc "A mapping for Field data belonging to each Field index in a Sphere."
  @type fields_data :: %{Field.index() => any}

  @typedoc "An arbitrary set of unique Field indices."
  @type fields :: MapSet.t(Field.index())

  @typedoc "A mapping for Field indices belonging to each Panel index."
  @type fields_at_panels :: %{panel_index => fields}

  @typedoc "A reference to a function to be called for each field during a compute frame."
  @type fn_ref :: {module(), function_name :: atom}

  @typedoc "Information about a particular Sphere, including its geometry."
  @type sphere :: %{
          :id => reference,
          :divisions => Sphere.divisions(),
          :field_centroids => FieldCentroids.centroid_sphere(),
          :interfield_centroids => InterfieldCentroids.interfield_centroid_sphere(),
          :fields_at_panels => fields_at_panels,
          :n_panels => non_neg_integer
        }

  ###
  #
  # API
  #
  ###

  @doc "Starts a SphereServer. This will automatically divide the Sphere into Panels (contiguous subsets of the Sphere’s Fields) based on the number of cores available and spawn the servers needed to run compute frames."

  @spec start_link(Sphere.divisions(), sphere_id) :: GenServer.on_start()

  def start_link(divisions, sphere_id) do
    GenServer.start_link(__MODULE__, [divisions, sphere_id],
      name: Registry.sphere_via_reg(sphere_id)
    )
  end

  @doc "Gets the data for each Field in the Sphere."

  @spec get_all_field_data(sphere_id) :: fields_data

  def get_all_field_data(sphere_id) do
    GenServer.call(Registry.sphere_via_reg(sphere_id), :get_all_field_data)
  end

  @doc "Starts a compute frame. The SphereServer will send `frame_complete` when finished."

  @spec start_frame(sphere_id, fn_ref, any, pid) :: :ok

  def start_frame(sphere_id, {module_name, function_name}, sphere_data, from) do
    per_field = {
      String.to_existing_atom("Elixir.#{module_name}"),
      String.to_existing_atom(function_name)
    }

    GenServer.cast(
      Registry.sphere_via_reg(sphere_id),
      {:start_frame, per_field, sphere_data, from}
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
  def init([divisions, sphere_id]) do
    sphere = init_sphere(divisions, sphere_id)

    {:ok, panel_supervisor} = PanelSupervisor.start_link(sphere)

    {:ok,
     %{
       sphere: sphere,
       panel_supervisor: panel_supervisor,
       in_frame: false
     }}
  end

  @spec init_sphere(Sphere.divisions(), sphere_id) :: sphere

  def init_sphere(divisions, sphere_id) do
    field_centroids = FieldCentroids.field_centroids(divisions)
    interfield_centroids = InterfieldCentroids.interfield_centroids(field_centroids, divisions)

    sphere = %{
      id: sphere_id,
      divisions: divisions,
      field_centroids: field_centroids,
      interfield_centroids: interfield_centroids
    }

    fields_at_panels = init_fields_at_panels(sphere)

    Map.merge(sphere, %{
      fields_at_panels: fields_at_panels,
      n_panels: length(Map.keys(fields_at_panels))
    })
  end

  @impl true
  def handle_call(:get_all_field_data, _from, state) do
    {:reply,
     Enum.reduce(Map.keys(state.sphere.fields_at_panels), %{}, fn panel_index, all_data ->
       panel_data = PanelServer.get_all_field_data(state.sphere.id, panel_index)

       Map.merge(
         all_data,
         panel_data
       )
     end), state}
  end

  ###
  # Panel computation
  ###

  # `init_fields_at_panels` Creates a `fields_at_panels` mapping panel indexes to the field
  # indexes that belong to that panel. Panels are formed by splitting the sphere into a number of
  # parts based on the available threads and efficient perimeter-minimizing geometries.

  defp init_fields_at_panels(sphere, n) when n == 4 do
    Sphere.for_all_fields(init_fields_at_panels(n), sphere.divisions, fn fields_at_panels,
                                                                         field_index ->
      panel_index_for_field = Shapes.face_of_4_hedron(sphere.field_centroids[field_index])

      update_in(
        fields_at_panels[panel_index_for_field],
        &MapSet.put(&1, field_index)
      )
    end)
  end

  defp init_fields_at_panels(sphere, n) when n == 8 do
    Sphere.for_all_fields(init_fields_at_panels(n), sphere.divisions, fn fields_at_panels,
                                                                         field_index ->
      panel_index_for_field = Shapes.face_of_8_hedron(sphere.field_centroids[field_index])

      update_in(
        fields_at_panels[panel_index_for_field],
        &MapSet.put(&1, field_index)
      )
    end)
  end

  defp init_fields_at_panels(n) when is_integer(n) do
    Enum.reduce(0..(n - 1), %{}, fn panel_index, fields_at_panels ->
      Map.put(fields_at_panels, panel_index, MapSet.new())
    end)
  end

  @spec init_fields_at_panels(sphere) :: fields_at_panels

  defp init_fields_at_panels(sphere) do
    threads = :erlang.system_info(:schedulers_online)

    cond do
      threads >= 8 -> init_fields_at_panels(sphere, 8)
      threads > 0 -> init_fields_at_panels(sphere, 4)
    end
  end

  ###
  # Frames
  ###

  @impl true
  def handle_cast({:start_frame, per_field, sphere_data, from}, state) do
    Enum.each(Map.keys(state.sphere.fields_at_panels), fn panel_index ->
      PanelServer.start_frame(
        state.sphere.id,
        panel_index,
        per_field,
        sphere_data
      )
    end)

    {:noreply,
     Map.merge(state, %{
       __reply_to__: from,
       __panels_ready_to_commit__: MapSet.new(),
       in_frame: true
     })}
  end

  @impl true
  def handle_cast({:__ready_to_commit_frame__, panel_index}, state) do
    state =
      update_in(
        state.__panels_ready_to_commit__,
        &MapSet.put(&1, panel_index)
      )

    if ready_to_commit_frame?(state), do: GenServer.cast(self(), :__commit_frame__)
    {:noreply, state}
  end

  @impl true
  def handle_cast(:__commit_frame__, state) do
    Enum.each(Map.keys(state.sphere.fields_at_panels), fn panel_index ->
      GenServer.call(Registry.panel_via_reg(state.sphere.id, panel_index), :__commit_frame__)
    end)

    if is_pid(state.__reply_to__), do: send(state.__reply_to__, :frame_complete)

    {:noreply,
     Map.drop(state, [
       :__reply_to__,
       :__panels_ready_to_commit__
     ])
     |> Map.put(:in_frame, false)}
  end

  defp ready_to_commit_frame?(state) do
    MapSet.size(state.__panels_ready_to_commit__) == state.sphere.n_panels
  end
end
