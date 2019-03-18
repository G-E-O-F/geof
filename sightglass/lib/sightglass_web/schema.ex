defmodule GEOF.SightglassWeb.Schema do
  use Absinthe.Schema

  import_types(GEOF.SightglassWeb.Schema.ContentTypes)

  alias GEOF.SightglassWeb.Resolvers

  query do
    @desc "Get a planet"
    field :planet, :planet do
      arg(:divisions, :integer, description: "The resolution of the model.")
      resolve(&Resolvers.Planet.get_planet/3)
    end

    @desc "Get a planet wireframe"
    field :planet_edges, :planet_edges do
      arg(:divisions, :integer, description: "The resolution of the model.")
      resolve(&Resolvers.Planet.get_planet_edges/3)
    end
  end

  mutation do
    @desc "Request a new frame from the model"
    field :elapse_frame, :frame do
      arg(:divisions, :integer)
      arg(:pattern, :string)

      resolve(&Resolvers.Planet.get_planet_frame/3)
    end
  end
end
