defmodule GEOF.SightglassWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  scalar :map do
    description("A mapping of some kind")
    # Since this is a map, there is no meaningful logic to put here.
    parse(fn map -> map end)
    serialize(fn map -> map end)
  end

  object :mesh do
    description("A planet's geometry as lists that can be cast to typed arrays")
    field(:position, list_of(:float))
    field(:normal, list_of(:float))
    field(:index, list_of(:integer))
    field(:vertex_order, :map)
  end

  object :planet do
    description("The basic representation of a planet")
    field(:id, :id)
    field(:divisions, :integer)
    field(:mesh, :mesh)
  end

  object :frame do
    description("A set of colors to apply to the sphere")
    field(:id, :id)
    field(:divisions, :integer)
    field(:pattern, :string)
    field(:colors, :map)
  end
end
