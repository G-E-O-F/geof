defmodule SightglassWeb.PageController do
  use SightglassWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
