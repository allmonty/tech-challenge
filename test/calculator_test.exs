defmodule CalculatorTest do
  use ExUnit.Case
  doctest FinancialSystem.Calculator

  alias FinancialSystem.Calculator
  alias FinancialSystem.Money
  alias FinancialSystem.Currency

  setup do
    {:ok, money} = Money.new(10, "BRL", 986, 2)

    {:ok,
     recipient: %{
       money: money,
       currency_usd: %Currency{alph_code: "USD", num_code: 840, decimal_points: 2},
       currency_brl: %Currency{alph_code: "BRL", num_code: 986, decimal_points: 2},
       currency_cny: %Currency{alph_code: "CNY", num_code: 156, decimal_points: 1}
     }}
  end

  # ====== Testing convert_currency ===== #

  test "#convert_currency should return money with the converted alph_code", state do
    %{money: money, currency_usd: currency} = state.recipient

    {:ok, converted_money} = Calculator.convert_currency(money, 0.31926, currency)

    assert converted_money.currency.alph_code == "USD"
  end

  test "#convert_currency should return money with the converted num_code", state do
    %{money: money, currency_usd: currency} = state.recipient

    {:ok, converted_money} = Calculator.convert_currency(money, 0.31926, currency)

    assert converted_money.currency.num_code == 840
  end

  test "#convert_currency should return money with the converted decimal_points", state do
    %{money: money, currency_usd: currency} = state.recipient

    {:ok, converted_money} = Calculator.convert_currency(money, 0.31926, currency)

    assert converted_money.currency.decimal_points == 2
  end

  test "#convert_currency should convert 10 reais to 3.19 dollars", state do
    %{money: money, currency_usd: currency} = state.recipient

    {:ok, converted_money} = Calculator.convert_currency(money, 0.31926, currency)
    converted_amount = Money.retrieve_unsplitted_amount(converted_money)

    assert converted_amount == 3.19
  end

  test "#convert_currency should convert 10 dollars to 31,32 reais", state do
    %{currency_usd: currency_usd, currency_brl: currency_brl} = state.recipient
    {:ok, money} = Money.new(10, currency_usd)

    {:ok, converted_money} = Calculator.convert_currency(money, 3.13224331, currency_brl)
    converted_amount = Money.retrieve_unsplitted_amount(converted_money)

    assert converted_amount == 31.32
  end

  test "#convert_currency should convert 10 dollars to 63.2 Chinese yuan", state do
    %{currency_usd: currency_usd, currency_cny: currency_cny} = state.recipient
    {:ok, money} = Money.new(10, currency_usd)

    {:ok, converted_money} = Calculator.convert_currency(money, 6.31991405, currency_cny)
    converted_amount = Money.retrieve_unsplitted_amount(converted_money)

    assert converted_amount == 63.2
  end

  test "#convert_currency should convert 0 dollars to 0 Chinese yuan", state do
    %{currency_usd: currency_usd, currency_cny: currency_cny} = state.recipient
    {:ok, money} = Money.new(0, currency_usd)

    {:ok, converted_money} = Calculator.convert_currency(money, 6.31991405, currency_cny)
    converted_amount = Money.retrieve_unsplitted_amount(converted_money)

    assert converted_amount == 0
  end

  # ====== Testing sum ===== #

  test "#sum should sum 0 reais to 10 reais returning 10", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.sum(money, 0)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 10
  end

  test "#sum should sum 10 reais to 10 reais returning 20", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.sum(money, 10)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 20
  end

  test "#sum should sum 10.57 reais to 10 reais returning 20.57", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.sum(money, 10.57)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 20.57
  end

  test "#sum should sum -15.57 reais to 10 reais returning error", state do
    %{money: money} = state.recipient

    {resp, _response} = Calculator.sum(money, -15.57)

    assert resp == :error
  end

  # ====== Testing subtract ===== #

  test "#subtract 10 reais from 10 reais returning 0", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.subtract(money, 10)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 0
  end

  test "#subtract 5.42 reais from 10 reais returning 4.58", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.subtract(money, 5.42)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 4.58
  end

  test "#subtract 0 reais from 10 reais returning 10", state do
    %{money: money} = state.recipient

    {:ok, added_money} = Calculator.subtract(money, 0)
    added_amount = Money.retrieve_unsplitted_amount(added_money)

    assert added_amount == 10
  end

  test "#subtract -15.57 reais from 10 reais returning error", state do
    %{money: money} = state.recipient

    {resp, _response} = Calculator.subtract(money, -15.57)

    assert resp == :error
  end
end
