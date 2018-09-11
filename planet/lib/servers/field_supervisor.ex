defmodule GEOF.Planet.FieldSupervisor do
  use Supervisor

  # API

  def start_link(divisions) do
    Supervisor.start_link(__MODULE__, [divisions])
  end

  # SERVER

  @impl true
  def init([divisions]) when is_integer(divisions) and divisions >= 0 do
    # One child per field, identified by field index

    children =
      GEOF.Planet.Sphere.for_all_fields([], divisions, fn acc, index ->
        [
          %{
            id: index,
            start: {
              GEOF.Planet.FieldServer,
              :start_link,
              [index]
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
