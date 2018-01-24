defmodule MoneyTest do
  use ExUnit.Case
  doctest FinancialSystem.Money

  alias FinancialSystem.Money

  setup do
    {:ok,
     recipient: %Money{
       code: "ABC",
       decimal_points: 3,
       int_part: 42,
       dec_part: 72
     }}
  end

  test "#new receiving a float should split it", state do
    %Money{code: code, decimal_points: dec_points} = state.recipient

    amount = 42.5

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} = Money.new(amount, code, dec_points)

    assert int_part == 42
    assert dec_part == 5
  end

  test "#new receiving a int should split it with dec_part 0", state do
    %Money{code: code, decimal_points: dec_points} = state.recipient

    amount = 42

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} = Money.new(amount, code, dec_points)

    assert int_part == 42
    assert dec_part == 0
  end
end
