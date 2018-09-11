defmodule GEOF.Planet.FieldServer do
  use GenServer
  import GEOF.Planet.Registry

  # API

  def start_link(sphere_id, index, adjacents) do
    GenServer.start_link(__MODULE__, [sphere_id, index, adjacents],
      name: field_via_reg(sphere_id, index)
    )
  end

  def get_data(sphere_id, index) do
    GenServer.call(field_via_reg(sphere_id, index), :get_data)
  end

  def get_state(sphere_id, index) do
    GenServer.call(field_via_reg(sphere_id, index), :get_state)
  end

  def iterate(sphere_id, index, module_name, func_name) do
    GenServer.cast(field_via_reg(sphere_id, index), {:iterate, module_name, func_name})
  end

  def finish_iteration(sphere_id, index) do
    GenServer.cast(field_via_reg(sphere_id, index), :finish_iteration)
  end

  # SERVER

  @impl true
  def init([sphere_id, index, adjacents]) do
    no_nil_adjacents = if adjacents.ne == nil, do: Map.delete(adjacents, :ne), else: adjacents

    {:ok,
     %{
       id: index,
       adjacents:
         Enum.map(
           no_nil_adjacents,
           fn {_, index} -> index end
         ),
       sphere: sphere_id,
       data: nil
     }}
  end

  @impl true
  def handle_cast(:finish_iteration, state) do
    {:noreply, Map.put(state, :data, Map.get(state, :next)) |> Map.delete(:next)}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_data, _from, state) do
    {:reply, Map.get(state, :data), state}
  end

  @impl true
  def handle_cast({:iterate, module_name, func_name}, state) do
    # Applies an arbitrary module's function with the current and adjacent fields' state
    {:noreply,
     Map.put(
       state,
       :next,
       apply(
         String.to_existing_atom("Elixir.#{module_name}"),
         func_name,
         [state, get_adjacents_data(state)]
       )
     )}
  end

  defp get_adjacents_data(state) do
    sphere_id = Map.get(state, :sphere)

    Enum.map(Map.get(state, :adjacents), fn index ->
      get_state(sphere_id, index)
    end)
  end
end
