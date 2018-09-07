defmodule SightglassWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :mesh do
    field(:position, list_of(:float))
    field(:normal, list_of(:float))
    field(:index, list_of(:integer))
  end

  object :planet do
    field(:id, :id)
    field(:divisions, :integer)
    field(:mesh, :mesh)
  end
end
