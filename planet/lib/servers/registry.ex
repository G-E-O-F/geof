defmodule GEOF.Planet.Registry do
  @moduledoc """
    Registers `gproc` process identifiers for all the servers.
  """

  defp via(term) do
    {:via, :gproc, {:n, :l, term}}
  end

  def sphere_via_reg(sphere_id) do
    via({:sphere, sphere_id})
  end

  def panel_supervisor_via_reg(sphere_id) do
    via({:panel_supervisor, sphere_id})
  end

  def panel_via_reg(sphere_id, panel_index) do
    via({:panel, sphere_id, panel_index})
  end
end
