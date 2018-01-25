defmodule MoneyTest do
  use ExUnit.Case
  doctest FinancialSystem.Money

  alias FinancialSystem.Money
  alias FinancialSystem.Currency

  setup do
    {:ok,
     recipient: %{
       alph_code: "ABC",
       num_code: 986,
       decimal_points: 3,
       int_part: 42,
       dec_part: 72,
       value: 42.72
     }}
  end

  # ======Testing the received amount=====#

  test "#new receiving a float should split it", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = 42.5

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} =
      Money.new(amount, alph_code, num_code, dec_points)

    assert int_part == 42
    assert dec_part == 5
  end

  test "#new receiving an int should split it with dec_part 0", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = 42

    {:ok, %Money{int_part: int_part, dec_part: dec_part}} =
      Money.new(amount, alph_code, num_code, dec_points)

    assert int_part == 42
    assert dec_part == 0
  end

  test "#new receiving a negative float should return error", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = -42.5

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving a negative int should return error", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = -42

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving a string in amount should return error", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = "teste"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving nil in amount should return error", state do
    %{alph_code: alph_code, num_code: num_code, decimal_points: dec_points} = state.recipient

    amount = "teste"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  # ======Testing the received alph_code=====#

  test "#new receiving valid alph_code should return ok", state do
    %{value: amount, num_code: num_code, decimal_points: dec_points} = state.recipient

    alph_code = "BRL"

    {:ok, %Money{currency: %Currency{alph_code: resp_alph_code}}} =
      Money.new(amount, alph_code, num_code, dec_points)

    assert resp_alph_code == alph_code
  end

  test "#new receiving 4 digits alph_code should return error", state do
    %{value: amount, num_code: num_code, decimal_points: dec_points} = state.recipient

    alph_code = "BRLA"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving 2 digits alph_code should return error", state do
    %{value: amount, num_code: num_code, decimal_points: dec_points} = state.recipient

    alph_code = "BR"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving empty string alph_code should return error", state do
    %{value: amount, num_code: num_code, decimal_points: dec_points} = state.recipient

    alph_code = ""

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  # ======Testing the received num_code=====#

  test "#new receiving valid num_code should return ok", state do
    %{value: amount, alph_code: alph_code, decimal_points: dec_points} = state.recipient

    num_code = 986

    {:ok, %Money{currency: %FinancialSystem.Currency{num_code: resp_num_code}}} =
      Money.new(amount, alph_code, num_code, dec_points)

    assert resp_num_code == num_code
  end

  test "#new receiving negative num_code should return ok", state do
    %{value: amount, alph_code: alph_code, decimal_points: dec_points} = state.recipient

    num_code = -986

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving 4 digits num_code should return ok", state do
    %{value: amount, alph_code: alph_code, decimal_points: dec_points} = state.recipient

    num_code = 9864

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving binary num_code should return ok", state do
    %{value: amount, alph_code: alph_code, decimal_points: dec_points} = state.recipient

    num_code = "9864"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving float num_code should return ok", state do
    %{value: amount, alph_code: alph_code, decimal_points: dec_points} = state.recipient

    num_code = 42.5

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  # ======Testing the received decimal_points=====#

  test "#new receiving float should return error", state do
    %{value: amount, num_code: num_code, alph_code: alph_code} = state.recipient

    dec_points = 2.5

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving string should return error", state do
    %{value: amount, num_code: num_code, alph_code: alph_code} = state.recipient

    dec_points = "2.5"

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving negative integer should return error", state do
    %{value: amount, num_code: num_code, alph_code: alph_code} = state.recipient

    dec_points = -2

    {resp, _response} = Money.new(amount, alph_code, num_code, dec_points)

    assert resp == :error
  end

  test "#new receiving positive integer should return ok", state do
    %{value: amount, num_code: num_code, alph_code: alph_code} = state.recipient

    dec_points = 2

    {:ok, %Money{currency: %FinancialSystem.Currency{decimal_points: resp_points}}} =
      Money.new(amount, alph_code, num_code, dec_points)

    assert resp_points == 2
  end

  # ======Testing retrieving unsplitted amount=====#

  test "#retrieve_unsplitted_amount receiving money with amount 42.123 and 2 dec_points should return 42.12",
       state do
    %{num_code: num_code, alph_code: alph_code} = state.recipient

    amount = 42.123
    dec_points = 2

    {:ok, money} = Money.new(amount, alph_code, num_code, dec_points)
    unsplitted = Money.retrieve_unsplitted_amount(money)

    assert unsplitted == 42.12
  end

  test "#retrieve_unsplitted_amount receiving money with amount 42.123 and 1 dec_points should return 42.1",
       state do
    %{num_code: num_code, alph_code: alph_code} = state.recipient

    amount = 42.123
    dec_points = 1

    {:ok, money} = Money.new(amount, alph_code, num_code, dec_points)
    unsplitted = Money.retrieve_unsplitted_amount(money)

    assert unsplitted == 42.1
  end

  test "#retrieve_unsplitted_amount receiving money with amount 42.156 and 1 dec_points should round to 42.2",
       state do
    %{num_code: num_code, alph_code: alph_code} = state.recipient

    amount = 42.156
    dec_points = 1

    {:ok, money} = Money.new(amount, alph_code, num_code, dec_points)
    unsplitted = Money.retrieve_unsplitted_amount(money)

    assert unsplitted == 42.2
  end

  test "#retrieve_unsplitted_amount receiving money with amount 42.156 and 0 dec_points should round to 42",
       state do
    %{num_code: num_code, alph_code: alph_code} = state.recipient

    amount = 42.156
    dec_points = 0

    {:ok, money} = Money.new(amount, alph_code, num_code, dec_points)
    unsplitted = Money.retrieve_unsplitted_amount(money)

    assert unsplitted == 42
  end
end
