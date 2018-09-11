defmodule GEOF.Planet.SphereServer do
  use GenServer

  # API

  def start_link(divisions) do
    sphere_id = make_ref()
    GenServer.start_link(__MODULE__, [divisions, sphere_id], name: sphere_via_registry(sphere_id))
  end

  defp sphere_via_registry(sphere_id) do
    GEOF.Planet.Registry.via({:sphere, sphere_id})
  end

  # SERVER

  @impl true
  def init([divisions, sphere_id]) do
    {:ok, supervisor} = GEOF.Planet.FieldSupervisor.start_link(divisions, sphere_id)

    {:ok,
     %{
       id: sphere_id,
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
