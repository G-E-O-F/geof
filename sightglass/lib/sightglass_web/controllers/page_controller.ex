defmodule GEOF.SightglassWeb.PageController do
  use GEOF.SightglassWeb, :controller

  def index(conn, _params) do
    text(conn, "GEOF Sightglass\nPlease use the WS GraphQL API for GEOF.Planet at /planet")
  end
end
