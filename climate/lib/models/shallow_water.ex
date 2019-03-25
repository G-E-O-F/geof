defmodule GEOF.Climate.ShallowWaterModel do
  @moduledoc """
    Solves the shallow water equations across the sphere.
    Based on the Spherepack algorithm in Fortran by John Adams and Paul Swarztrauber,
    retrieved from github.com:jlokimlin/spherepack
  """

  import :math

  @deg_to_rad pi() / 180

  @sphere_defaults %{
    # planet radius = earth's
    aa: 6.37122e6,
    # rate of rotation = earth's
    omega: 7.292e-5,
    # todo: what's this?
    f_0: 2.0 * omega,
    # todo: what's this?
    u_0: 40.0,
    # todo: what's this?
    p_0: 2.94e4,
    alpha: 60 * @deg_to_rad,
    # time step in seconds
    dt: 300.0
  }

  def sphere_defaults, do: @sphere_defaults
end
