defmodule GEOF.Planet.Registry do
  defp via(term) do
    {:via, :gproc, {:n, :l, term}}
  end

  def sphere_via_reg(sphere_id) do
    via({:sphere, sphere_id})
  end

  def field_via_reg(sphere_id, index) do
    via({:field, sphere_id, index})
  end
end
