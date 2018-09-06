defmodule SightglassWeb.Schema do
  use Absinthe.Schema

  import_types(SightglassWeb.Schema.ContentTypes)

  alias SightglassWeb.Resolvers

  query do
    @desc "Get a planet"
    field :planet, :planet do
      resolve(&Resolvers.Content.get_planet/3)
    end
  end
end
