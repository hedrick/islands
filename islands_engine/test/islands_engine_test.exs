defmodule IslandsEngineTest do
  use ExUnit.Case
  alias IslandsEngine.{Rules, Game}
  doctest IslandsEngine
  doctest Rules

  # board.ex tests
  test "create new board"  do
    assert Rules.new() == %Rules{}
  end

  test "greets the world" do
    assert IslandsEngine.hello() == :world
  end

  test "islands are set" do
    {:ok, game} = Game.start_link("Dino")
    Game.add_player(game, "Pebbles")
    assert Game.set_islands(game, :player1) == {:error, :not_all_islands_positioned}

    Game.position_island(game, :player1, :atoll, 1, 1)
    Game.position_island(game, :player1, :dot, 1, 4)
    Game.position_island(game, :player1, :l_shape, 1, 5)
    Game.position_island(game, :player1, :s_shape, 5, 1)
    Game.position_island(game, :player1, :square, 5, 5)
    refute Game.set_islands(game, :player1) == {:error, :not_all_islands_positioned}
  end

  test "guess coordinate" do
    {:ok, game} = Game.start_link("Miles")
    assert Game.guess_coordinate(game, :player1, 1, 1) == :error

    Game.add_player(game, "Trane")
    Game.position_island(game, :player1, :dot, 1, 1)
    Game.position_island(game, :player2, :square, 1, 1)

    state_data = :sys.get_state(game)
    state_data = :sys.replace_state(game, fn _data ->
      %{state_data | rules: %Rules{state: :player1_turn}}
    end)
    assert state_data.rules.state == :player1_turn

    assert Game.guess_coordinate(game, :player1, 5, 5) == {:miss, :none, :no_win}
    assert Game.guess_coordinate(game, :player1, 3, 1) == :error
    
    assert Game.guess_coordinate(game, :player2, 1, 1) == {:hit, :dot, :win}
  end
end
