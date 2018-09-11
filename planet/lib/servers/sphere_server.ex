defmodule GEOF.Planet.SphereServer do
  use GenServer

  # API

  def start_link(divisions) do
    GenServer.start_link(__MODULE__, [divisions])
  end

  # SERVER

  @impl true
  def init([divisions]) do
    {:ok, supervisor} = GEOF.Planet.FieldSupervisor.start_link(divisions)

    {:ok,
     %{
       divisions: divisions,
       geometry: %{
         field_centroids: nil,
         interfield_centroids: nil,
         mesh: nil
       },
       supervisor: supervisor
     }}
  end

  # TODO: add `handle_cast` and `cast` to fields; handle responses at `handle_info`
  # May need to specify the iteration cycle and store some way of determining when it's done.
end
