defmodule IslandsEngineTest do
  use ExUnit.Case
  alias IslandsEngine.{Rules}
  doctest IslandsEngine
  doctest Rules

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end
end
