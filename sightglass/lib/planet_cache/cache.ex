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
    sphere_id = UUID.uuid1()

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
      Map.put_new(state, sphere_id, pid: sspid, reporter_process: opts[:reporter_process])
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
  def handle_info({:inactive, sphere_id}, state) do
    IO.puts('Closing sphereServer due to inactivity: #{sphere_id}}')
    :ok = GenServer.stop(state[sphere_id][:pid])

    if is_pid(state[sphere_id][:reporter_process]),
      do: send(state[sphere_id][:reporter_process], {:terminated, sphere_id})

    {
      :noreply,
      Map.delete(state, sphere_id)
    }
  end
end
