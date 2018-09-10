defmodule GEOF.Planet.SphereServer do
  use GenServer

  @impl true
  def init([divisions, model]) do
    {:ok,
     %{
       divisions: divisions,
       model: model,
       geometry: %{
         field_centroids: nil,
         interfield_centroids: nil,
         mesh: nil
       },
       field_servers:
         GEOF.Planet.Sphere.for_all_fields(
           %{},
           divisions,
           fn acc, index ->
             {:ok, pid} =
               GenServer.start_link(
                 GEOF.Planet.FieldServer,
                 [index, GEOF.Planet.Pattern.highlight_icosahedron_on_field(index, divisions)]
               )

             Map.put(acc, index, pid)
           end
         )
     }}

    # TODO: give field servers the PIDs of the adjacent fields' servers
  end

  # TODO: add `handle_cast` and `cast` to fields; handle responses at `handle_info`
  # May need to specify the iteration cycle and store some way of determining when it's done.

  @impl true
  def handle_call(:tick, _from, state) do
    result =
      Map.get(state, :field_servers)
      |> Enum.reduce(%{}, fn {index, pid}, acc ->
        Map.put(acc, index, GenServer.call(pid, :tick))
      end)

    {:reply, result, state}
  end

  @impl true
  def terminate(_reason, state) do
    Enum.each(
      Map.get(state, :field_servers),
      fn {index, pid} -> GenServer.stop(pid) end
    )
  end
end
