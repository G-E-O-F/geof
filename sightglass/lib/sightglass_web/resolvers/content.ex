defmodule SightglassWeb.Resolvers.Content do
  def list_posts(_parent, _args, _resolution) do
    {:ok, Sightglass.Content.list_posts()}
  end
end
