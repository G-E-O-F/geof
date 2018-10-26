defmodule GEOF.Planet.Registry do
  defp via(term) do
    {:via, :gproc, {:n, :l, term}}
  end

  def sphere_via_reg(sphere_id) do
    via({:sphere, sphere_id})
  end

  def panel_via_reg(sphere, panel_index) do
    via({:panel, sphere.id, panel_index})
  end
end
