defmodule GEOF.Planet.SphereServer do
  use GenServer

  import GEOF.Planet.Registry
  import GEOF.Planet.Geometry.FieldCentroids
  import GEOF.Planet.Geometry.InterfieldCentroids
  import GEOF.Planet.Sphere
  import GEOF.Shapes

  # API

  def start_link(divisions) do
    sphere_id = make_ref()
    GenServer.start_link(__MODULE__, [divisions, sphere_id], name: sphere_via_reg(sphere_id))
  end

  # SERVER

  @impl true
  def init([divisions, sphere_id]) do
    field_centroids = field_centroids(divisions)
    interfield_centroids = interfield_centroids(field_centroids, divisions)

    sphere = %{
      id: sphere_id,
      divisions: divisions,
      field_centroids: field_centroids,
      interfield_centroids: interfield_centroids
    }

    sphere = Map.put(sphere, :field_sets, get_field_sets(sphere))

    {:ok, panel_supervisor} = GEOF.Planet.PanelSupervisor.start_link(sphere)

    {:ok,
     %{
       sphere: sphere,
       panel_supervisor: panel_supervisor
     }}
  end

  defp get_field_sets(sphere) do
    threads = :erlang.system_info(:schedulers_online)

    cond do
      threads > 0 -> get_field_sets(sphere, 4)
    end
  end

  defp get_field_sets(sphere, n) when n == 4 do
    field_sets =
      Enum.reduce(0..(n - 1), %{}, fn panel_index, field_sets ->
        Map.put(field_sets, panel_index, MapSet.new())
      end)

    for_all_fields(field_sets, sphere.divisions, fn field_sets, field_index ->
      panel_index_for_field = face_of_4_hedron(sphere.field_centroids[field_index])

      update_in(
        field_sets[panel_index_for_field],
        &MapSet.put(&1, field_index)
      )
    end)
  end

  # TODO: add `handle_cast` and `cast` to fields; handle responses at `handle_info`
  # May need to specify the iteration cycle and store some way of determining when it's done.
end
