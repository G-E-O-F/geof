defmodule SightglassWeb.Schema do
  use Absinthe.Schema

  import_types(SightglassWeb.Schema.ContentTypes)

  alias SightglassWeb.Resolvers

  query do
    @desc "Get a planet"
    field :planet, :planet do
      arg(:divisions, :integer, description: "The resolution of the model.")
      resolve(&Resolvers.Planet.get_planet/3)
    end
  end
end
