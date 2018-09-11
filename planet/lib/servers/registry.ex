defmodule GEOF.Planet.Registry do
  def via(term) do
    {:via, :gproc, {:n, :l, term}}
  end
end
