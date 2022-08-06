defmodule GenserverTestsTest do
  use ExUnit.Case
  doctest GenserverTests

  test "greets the world" do
    assert GenserverTests.hello() == :world
  end
end
