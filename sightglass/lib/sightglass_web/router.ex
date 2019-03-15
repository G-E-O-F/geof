defmodule GEOF.SightglassWeb.Router do
  use GEOF.SightglassWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/" do
    pipe_through(:browser)
    get("/", GEOF.SightglassWeb.PageController, :index)
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
