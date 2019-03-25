defmodule GEOF.Sightglass.PlanetCache.Cache do
  use GenServer

  alias GEOF.Planet.SphereServer

  # 40 seconds
  @planet_timeout 40 * 1000

  # based on boilerplate retrieved from https://thoughtbot.com/blog/make-phoenix-even-faster-with-a-genserver-backed-key-value-store

  ###
  #
  # API
  #
  ###

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def start_planet(divisions) do
    GenServer.call(__MODULE__, {:start_planet, divisions})
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
  def init() do
    {
      :ok,
      %{}
    }
  end

  @impl true
  def handle_call({:start_planet, divisions}, _from, state) do
    sphere_id = UUID.uuid5(:dns, "sightglass.geof.io")

    sspid =
      SphereServer.start_link(
        divisions,
        sphere_id,
        @planet_timeout,
        self()
      )

    {
      :reply,
      sphere_id,
      Map.put_new(state, sphere_id, sspid)
    }
  end

  @impl true
  def handle_call({:end_planet, sphere_id}, _from, state) do
    {
      :reply,
      GenServer.stop(state[sphere_id], :ended),
      Map.delete(state, sphere_id)
    }
  end

  @impl true
  def handle_info({:timeout, sphere_id}, state) do
    GenServer.stop(state[sphere_id], :inactivity)

    {
      :noreply,
      Map.delete(state, sphere_id)
    }
  end
end
