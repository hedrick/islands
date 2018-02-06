defmodule IslandsEngine.Rules do
  alias __MODULE__

  defstruct state: :initialized

  @doc ~S"""
  Returns a new Rules struct.

  ## Examples

      iex> rules = Rules.new()
      iex> rules.state == :initialized
      true
  """
  def new(), do: %Rules{}

  @doc ~S"""
  Checks for state change. If :add_player, rules.state == :players_set

  ## Examples

      iex> rules = Rules.new()
      iex> {:ok, rules} = Rules.check(rules, :add_player)
      iex> rules.state == :players_set
      true
      iex> rules2 = Rules.new()
      iex> Rules.check(rules2, :fart)
      :error
  """
  def check(%Rules{state: :initialized} = rules, :add_player), do:
    {:ok, %Rules{rules | state: :players_set}}
  def check(_state, _action), do: :error

end