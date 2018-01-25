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
end
