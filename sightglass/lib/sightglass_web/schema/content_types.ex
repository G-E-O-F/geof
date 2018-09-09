defmodule SightglassWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :mesh do
    description("A planet's geometry as lists that can be cast to typed arrays")
    field(:position, list_of(:float))
    field(:normal, list_of(:float))
    field(:index, list_of(:integer))
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
    field(:colors, :frame_colors)
  end

  scalar :frame_colors do
    description("A mapping of vertex index to RGB tuples")
    # Since this is a map, there is no meaningful logic to put here.
    parse(fn map ->
      IO.inspect(map)
      map
    end)

    serialize(fn map ->
      IO.inspect(map)
      map
    end)
  end
end
