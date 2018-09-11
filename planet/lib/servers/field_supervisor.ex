defmodule GEOF.Planet.FieldSupervisor do
  use Supervisor
  import GEOF.Planet.Field

  # API

  def start_link(divisions, sphere_id) do
    Supervisor.start_link(__MODULE__, [divisions, sphere_id])
  end

  # SERVER

  @impl true
  def init([divisions, sphere_id]) do
    # One child per field, identified by field index

    children =
      GEOF.Planet.Sphere.for_all_fields([], divisions, fn acc, index ->
        [
          %{
            id: index,
            start: {
              GEOF.Planet.FieldServer,
              :start_link,
              [sphere_id, index, adjacents(index, divisions)]
            }
          }
          | acc
        ]
      end)

    Supervisor.init(
      children,
      # We're all in this together <3
      strategy: :one_for_all
    )
  end
end
