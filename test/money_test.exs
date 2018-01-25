defmodule MoneyTest do
  use ExUnit.Case
  doctest FinancialSystem.Money

  alias FinancialSystem.Money

  setup do
    {:ok,
     recipient: %{
       code: "ABC",
       decimal_points: 3,
       int_part: 42,
       dec_part: 72,
       value: 42.72
     }}
  end

  #======Testing about the received amount=====#

  test "#new receiving a float should split it", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = 42.5

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} = Money.new(amount, code, dec_points)

    assert int_part == 42
    assert dec_part == 5
  end

  test "#new receiving an int should split it with dec_part 0", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = 42

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} = Money.new(amount, code, dec_points)

    assert int_part == 42
    assert dec_part == 0
  end

  test "#new receiving a negative float should return error", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = -42.5

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving a negative int should return error", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = -42

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving a string in amount should return error", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = "teste"

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving nil in amount should return error", state do
    %{code: code, decimal_points: dec_points} = state.recipient

    amount = "teste"

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  #======Testing about the received code=====#

  test "#new receiving valid code should return ok", state do
    %{value: amount, decimal_points: dec_points} = state.recipient

    code = "BRL"

    {:ok, %Money{code: resp_code}} = Money.new(amount, code, dec_points)

    assert resp_code == code
  end

  test "#new receiving 4 digits code should return error", state do
    %{value: amount, decimal_points: dec_points} = state.recipient

    code = "BRLA"

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving 2 digits code should return error", state do
    %{value: amount, decimal_points: dec_points} = state.recipient

    code = "BR"

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving empty string code should return error", state do
    %{value: amount, decimal_points: dec_points} = state.recipient

    code = ""

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  #======Testing about the received decimal_points=====#

  test "#new receiving float should return error", state do
    %{value: amount, code: code} = state.recipient

    dec_points = 2.5

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving string should return error", state do
    %{value: amount, code: code} = state.recipient

    dec_points = "2.5"

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving negative integer should return error", state do
    %{value: amount, code: code} = state.recipient

    dec_points = -2

    {resp, _response} = Money.new(amount, code, dec_points)

    assert resp == :error
  end

  test "#new receiving positive integer should return ok", state do
    %{value: amount, code: code} = state.recipient

    dec_points = 2

    {:ok, %Money{decimal_points: resp_points}} = Money.new(amount, code, dec_points)

    assert resp_points == 2
  end
end
