defmodule SightglassWeb.Resolvers.Content do
  def get_planet(_parent, _args, _resolution) do
    {:ok, Sightglass.Content.get_planet()}
  end
end
