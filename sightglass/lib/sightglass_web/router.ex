defmodule GEOF.SightglassWeb.Router do
  use GEOF.SightglassWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api" do
    pipe_through(:api)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: GEOF.SightglassWeb.Schema,
      socket: GEOF.SightglassWeb.PlanetSocket
    )

    forward("/", Absinthe.Plug, schema: GEOF.SightglassWeb.Schema)
  end
end
