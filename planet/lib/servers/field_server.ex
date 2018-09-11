defmodule GEOF.Planet.FieldServer do
  use GenServer

  # API

  def start_link(index) do
    GenServer.start_link(__MODULE__, [], name: via_registry(index))
  end

  defp via_registry(index) do
    {:via, :gproc, {:n, :l, index}}
  end

  # SERVER

  @impl true
  def init(_) do
    {:ok, %{}}
  end
end
