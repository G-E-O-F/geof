defmodule GEOF.Planet.FieldServer do
  use GenServer

  @impl true
  def init([index, color]) do
    {:ok, %{index: index, color: color}}
  end

  @impl true
  def handle_call(:tick, _from, state) do
    {:reply, Map.get(state, :color), state}
  end
end
