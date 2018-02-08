defmodule IslandsEngineTest do
  use ExUnit.Case
  alias IslandsEngine.{Rules, Game, GameSupervisor}
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

  test "supervisor starts game process" do
    {:ok, _game} = new_game()
    assert Supervisor.count_children(GameSupervisor) == %{active: 1, specs: 1, supervisors: 0, workers: 1}
    GameSupervisor.stop_game("wibble")
  end

  test "supervisor stops game process" do
    {:ok, game} = new_game()
    GameSupervisor.stop_game("wibble")
    assert Process.alive?(game) == false
  end

  test "no other process is registered with 'name' in Game.via_tuple" do
    {:ok, _game} = new_game()
    GameSupervisor.start_game("wibble")
    via = Game.via_tuple("wibble")
    assert via == {:via, Registry, {Registry.Game, "wibble"}}
    GameSupervisor.stop_game("wibble")
    assert GenServer.whereis(via) == nil
  end

  test "GenServer for Game is cleaned up on GameSupervisor.stop_game" do
    {:ok, _game} = new_game()
    via = Game.via_tuple("wibble")
    assert via == {:via, Registry, {Registry.Game, "wibble"}}
    GameSupervisor.stop_game("wibble")
    assert :ets.lookup(:game_state, "wibble") == []
  end

  defp new_game() do
    {:ok, _game} = GameSupervisor.start_game("wibble")
  end
end
