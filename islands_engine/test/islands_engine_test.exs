defmodule IslandsEngineTest do
  use ExUnit.Case
  alias IslandsEngine.{Rules}
  doctest IslandsEngine
  doctest Rules

  # board.ex tests
  test "create new board"  do
    assert Rules.new() == %Rules{}
  end

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end
end
