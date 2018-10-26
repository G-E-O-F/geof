defmodule GEOF.Planet.PanelSupervisor do
  use Supervisor

  # API

  def start_link(sphere) do
    Supervisor.start_link(__MODULE__, [sphere])
  end

  # SERVER

  @impl true
  def init([sphere]) do
    Supervisor.init(
      get_children(sphere),
      strategy: :one_for_all
    )
  end

  defp get_children(sphere) do
    Enum.map(
      Map.keys(sphere.field_sets),
      fn panel_index ->
        %{
          id: {sphere.id, panel_index},
          start: {
            GEOF.Planet.PanelServer,
            :start_link,
            [sphere, panel_index, sphere.field_sets[panel_index]]
          }
        }
      end
    )
  end
end
