defmodule SightglassWeb.Schema do
  use Absinthe.Schema

  import_types(SightglassWeb.Schema.ContentTypes)

  alias SightglassWeb.Resolvers

  query do
    @desc "Get all posts"
    field :posts, list_of(:post) do
      resolve(&Resolvers.Content.list_posts/3)
    end
  end
end
