defmodule GEOF.Sightglass.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(GEOF.SightglassWeb.Endpoint, []),
      # Start the subscription service
      supervisor(Absinthe.Subscription, [GEOF.SightglassWeb.Endpoint])
      # Start GEOF model services
      # todo: (create and) start a supervisor that keeps planetServers cached and alive.
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GEOF.Sightglass.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GEOF.SightglassWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
