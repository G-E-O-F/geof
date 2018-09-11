defmodule GEOF.Planet.FieldServer do
  use GenServer
  import GEOF.Planet.Registry

  # API

  def start_link(sphere_id, index) do
    GenServer.start_link(__MODULE__, [sphere_id], name: field_via_reg(sphere_id, index))
  end

  def set_data(sphere_id, index, new_data) do
    GenServer.cast(field_via_reg(sphere_id, index), {:set_data, new_data})
  end

  # SERVER

  @impl true
  def init([sphere_id]) do
    {:ok,
     %{
       sphere: sphere_id,
       data: nil
     }}
  end

  @impl true
  def handle_cast({:set_data, new_data}, state) do
    {:noreply, Map.put(state, :data, new_data)}
  end
end
