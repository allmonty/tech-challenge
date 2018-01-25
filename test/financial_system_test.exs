defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem

  # test "User should be able to transfer money to another account" do
  #   assert false
  # end

  # test "User cannot transfer if not enough money available on the account" do
  #   assert false
  # end

  # test "A transfer should be cancelled if an error occurs" do
  #   assert false
  # end

  # test "A transfer can be splitted between 2 or more accounts" do
  #   assert false
  # end

  test "User should be able to exchange money between different currencies" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl} = FinancialSystem.Money.new(42.72, currency_brl)

    assert money_brl.int_part == 42
    assert money_brl.dec_part == 72

    real_to_dollar = 0.31926

    currency_usd = %FinancialSystem.Currency{alph_code: "USD", num_code: 840, decimal_points: 2}
    {:ok, money_usd} = FinancialSystem.Calculator.convert_currency(money_brl, real_to_dollar, currency_usd)

    assert money_usd.int_part == 13
    assert money_usd.dec_part == 6387872
  end

  test "Currencies should be in compliance with ISO 4217" do
    currency = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}

    assert currency.alph_code == "BRL"
    assert currency.num_code == 986
    assert currency.decimal_points == 2
  end
end
