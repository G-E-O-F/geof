defmodule GEOF.Sightglass.PlanetCache.Cache do
  use GenServer

  alias GEOF.Planet.SphereServer

  @planet_timeout 30 * 1000
  @planet_timeout_max 120 * 1000

  # based on boilerplate retrieved from https://thoughtbot.com/blog/make-phoenix-even-faster-with-a-genserver-backed-key-value-store

  ###
  #
  # API
  #
  ###

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def start_planet(opts) do
    GenServer.call(__MODULE__, {:start_planet, opts})
  end

  def get_planet_field_data(sphere_id) do
    GenServer.call(__MODULE__, {:get_planet_field_data, sphere_id})
  end

  def get_planet_basic_geometry(sphere_id) do
    GenServer.call(__MODULE__, {:get_planet_basic_geometry, sphere_id})
  end

  def run_frame(sphere_id, field_fn_ref, sphere_data \\ nil) do
    GenServer.cast(__MODULE__, {:run_frame, sphere_id, field_fn_ref, sphere_data})
  end

  def end_planet(sphere_id) do
    GenServer.call(__MODULE__, {:end_planet, sphere_id})
  end

  ###
  #
  # Server
  #
  ###

  @impl true
  def init(_args) do
    {
      :ok,
      %{}
    }
  end

  @impl true
  def handle_call({:start_planet, opts}, _from, state) do
    sphere_id = UUID.uuid1(:hex)

    timeout_duration =
      cond do
        opts[:timeout_duration] < @planet_timeout_max -> opts[:timeout_duration]
        true -> @planet_timeout
      end

    {:ok, sspid} =
      SphereServer.start_link(
        opts[:divisions],
        sphere_id,
        timeout_duration,
        self()
      )

    {
      :reply,
      sphere_id,
      Map.put_new(state, sphere_id, pid: sspid, requester: opts[:requester])
    }
  end

  @impl true
  def handle_call({:get_planet_field_data, sphere_id}, _from, state) do
    cond do
      Map.has_key?(state, sphere_id) ->
        {
          :reply,
          SphereServer.get_all_field_data(sphere_id),
          state
        }

      true ->
        {:reply, :not_found, state}
    end
  end

  @impl true
  def handle_call({:get_planet_basic_geometry, sphere_id}, _from, state) do
    cond do
      Map.has_key?(state, sphere_id) ->
        {
          :reply,
          SphereServer.get_basic_geometry(sphere_id),
          state
        }

      true ->
        {:reply, :not_found, state}
    end
  end

  @impl true
  def handle_call({:end_planet, sphere_id}, _from, state) do
    cond do
      Map.has_key?(state, sphere_id) ->
        {
          :reply,
          GenServer.stop(state[sphere_id][:pid]),
          Map.delete(state, sphere_id)
        }

      true ->
        {:reply, :not_found, state}
    end
  end

  @impl true
  def handle_cast({:run_frame, sphere_id, field_fn_ref, sphere_data}, state) do
    if Map.has_key?(state, sphere_id) do
      if SphereServer.in_frame?(sphere_id) do
        send(state[sphere_id][:requester], :busy)
      else
        SphereServer.start_frame(sphere_id, field_fn_ref, sphere_data, self())
        # send nothing
      end
    else
      IO.puts('〘PlanetCache〙〘run_frame〙no sphereServer monitored for id #{sphere_id}')
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:inactive, sphere_id}, state) do
    :ok = GenServer.stop(state[sphere_id][:pid])

    if is_pid(state[sphere_id][:requester]),
      do: send(state[sphere_id][:requester], {:terminated, sphere_id})

    {
      :noreply,
      Map.delete(state, sphere_id)
    }
  end

  @impl true
  def handle_info({:frame_complete, sphere_id}, state) do
    if Map.has_key?(state, sphere_id) do
      send(
        state[sphere_id][:requester],
        {
          :frame_complete,
          SphereServer.get_all_field_data(sphere_id)
        }
      )
    else
      IO.puts('〘PlanetCache〙〘frame_complete〙no sphereServer monitored for id #{sphere_id}')
    end

    {:noreply, state}
  end
end
