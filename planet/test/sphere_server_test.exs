defmodule GEOF.Planet.SphereServerTest do
  use ExUnit.Case

  alias GEOF.Planet.SphereServer

  doctest GEOF.Planet.SphereServer

  test "initializes" do
    d = 17
    initial_count = :erlang.system_info(:process_count)

    assert {:ok, sspid} = SphereServer.start_link(d)

    assert :erlang.system_info(:process_count) == initial_count + 2 + 4
  end
end
