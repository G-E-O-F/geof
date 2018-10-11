defmodule GEOF.Planet.PanelSupervisor do
  use Supervisor

  # API

  def start_link(sphere) do
    Supervisor.start_link(__MODULE__, [sphere])
  end

  # SERVER

  @impl true
  def init([sphere]) do
    children = get_children(sphere)

    Supervisor.init(
      children,
      strategy: :one_for_all
    )
  end

  defp get_children(sphere) do
    field_sets = Map.get(sphere, :field_sets)

    Enum.map(
      Map.keys(field_sets),
      fn panel_index ->
        %{
          id: {Map.get(sphere, :id), panel_index},
          start: {
            GEOF.Planet.PanelServer,
            :start_link,
            [sphere, panel_index, Map.get(field_sets, panel_index)]
          }
        }
      end
    )
  end
end
