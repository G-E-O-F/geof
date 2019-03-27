defmodule GEOF.SightglassWeb.Schema do
  use Absinthe.Schema

  import_types(GEOF.SightglassWeb.Schema.ContentTypes)

  alias GEOF.SightglassWeb.Resolvers

  query do
    @desc "Get a planet mesh"
    field :planet_mesh, :planet_mesh do
      arg(:id, :string, description: "The sphere ID returned after requisitioning a new planet.")
      resolve(&Resolvers.Planet.get_planet_mesh/3)
    end

    @desc "Get a planet wireframe"
    field :planet_wireframe, :planet_wireframe do
      arg(:id, :string, description: "The sphere ID returned after requisitioning a new planet.")
      resolve(&Resolvers.Planet.get_planet_wireframe/3)
    end
  end

  mutation do
    @desc "Requisition a new planet"
    field :create_planet, :planet do
      arg(:divisions, :integer)
      resolve(&Resolvers.Planet.create_planet/3)
    end
  end
end
