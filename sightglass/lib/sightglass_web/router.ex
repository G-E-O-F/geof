defmodule SightglassWeb.Router do
  use SightglassWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api" do
    pipe_through(:api)

    forward("/graphiql", Absinthe.Plug.GraphiQL,
      schema: SightglassWeb.Schema,
      socket: SightglassWeb.PlanetSocket
    )

    forward("/", Absinthe.Plug, schema: SightglassWeb.Schema)
  end
end
