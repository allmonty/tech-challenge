defmodule FinancialSystemTest do
  use ExUnit.Case
  doctest FinancialSystem

  alias FinancialSystem.Money

  test "User cannot transfer if not enough money available on the account" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl1} = FinancialSystem.Money.new(10, currency_brl)
    account1 = FinancialSystem.Account.new("Allan", money_brl1)

    {:ok, money_brl2} = FinancialSystem.Money.new(42.72, currency_brl)
    account2 = FinancialSystem.Account.new("David", money_brl2)

    {resp, _response} = FinancialSystem.transfer_money(100, account1, account2)

    assert resp == :error
  end

  test "A transfer should be cancelled if an error occurs" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl1} = FinancialSystem.Money.new(10, currency_brl)
    account_before_1 = FinancialSystem.Account.new("Allan", money_brl1)

    {:ok, money_brl2} = FinancialSystem.Money.new(42.72, currency_brl)
    account_before_2 = FinancialSystem.Account.new("David", money_brl2)

    {:error, %{account_from: account_a, account_to: account_b}} =
      FinancialSystem.transfer_money(100, account_before_1, account_before_2)

    assert account_a == account_before_1
    assert account_b == account_before_2
  end

  test "A transfer can be splitted between 2 or more accounts" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}

    {:ok, payment} = FinancialSystem.Money.new(50, currency_brl)

    {:ok, money_brl1} = FinancialSystem.Money.new(50, currency_brl)
    receiver = FinancialSystem.Account.new("Allan", money_brl1)

    {:ok, money_brl1} = FinancialSystem.Money.new(50, currency_brl)
    account_1 = FinancialSystem.Account.new("Monteiro", money_brl1)

    {:ok, money_brl2} = FinancialSystem.Money.new(50, currency_brl)
    account_2 = FinancialSystem.Account.new("David", money_brl2)

    {:ok, transition} =
      FinancialSystem.payment_splitting_money_in_parts(receiver, payment, [
        {2, account_1},
        {3, account_2}
      ])

    assert Money.retrieve_unsplitted_amount(transition.receiver.funds) == 100
    assert Money.retrieve_unsplitted_amount(Enum.at(transition.payers, 0).funds) == 30
    assert Money.retrieve_unsplitted_amount(Enum.at(transition.payers, 1).funds) == 20
  end

  test "User should be able to exchange money between different currencies" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl} = FinancialSystem.Money.new(42.72, currency_brl)

    assert money_brl.int_part == 42
    assert money_brl.dec_part == 72

    real_to_dollar = 0.31926

    currency_usd = %FinancialSystem.Currency{alph_code: "USD", num_code: 840, decimal_points: 2}

    {:ok, money_usd} =
      FinancialSystem.Calculator.convert_currency(money_brl, real_to_dollar, currency_usd)

    assert money_usd.int_part == 13
    assert money_usd.dec_part == 6_387_872
  end

  test "Currencies should be in compliance with ISO 4217" do
    currency = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}

    assert currency.alph_code == "BRL"
    assert currency.num_code == 986
    assert currency.decimal_points == 2
  end

  # ============================ #
  # ==== Transfering money ===== #
  # ============================ #

  # => "User should be able to transfer money to another account"

  test "#transfer_money between same currency accounts" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}

    {:ok, money_brl1} = FinancialSystem.Money.new(42.72, currency_brl)
    account1 = FinancialSystem.Account.new("Allan", money_brl1)

    {:ok, money_brl2} = FinancialSystem.Money.new(42.72, currency_brl)
    account2 = FinancialSystem.Account.new("David", money_brl2)

    {:ok, %{from: ac1, to: ac2}} = FinancialSystem.transfer_money(10, account1, account2)
    amount1 = FinancialSystem.Money.retrieve_unsplitted_amount(ac1.funds)
    amount2 = FinancialSystem.Money.retrieve_unsplitted_amount(ac2.funds)

    assert amount1 == 32.72
    assert amount2 == 52.72
  end

  test "#transfer_money between different currency accounts" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl1} = FinancialSystem.Money.new(42.72, currency_brl)
    account1 = FinancialSystem.Account.new("Allan", money_brl1)

    currency_usd = %FinancialSystem.Currency{alph_code: "USD", num_code: 840, decimal_points: 2}
    {:ok, money_brl2} = FinancialSystem.Money.new(42.72, currency_usd)
    account2 = FinancialSystem.Account.new("David", money_brl2)

    {resp, _response} = FinancialSystem.transfer_money(10, account1, account2)

    assert resp == :error
  end

  test "#transfer_money_converting between different currency accounts" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl1} = FinancialSystem.Money.new(20, currency_brl)
    account1 = FinancialSystem.Account.new("Allan", money_brl1)

    currency_usd = %FinancialSystem.Currency{alph_code: "USD", num_code: 840, decimal_points: 2}
    {:ok, money_brl2} = FinancialSystem.Money.new(10, currency_usd)
    account2 = FinancialSystem.Account.new("David", money_brl2)

    {:ok, %{from: ac1, to: ac2}} =
      FinancialSystem.transfer_money_converting(10, 0.31825, account1, account2)

    amount1 = FinancialSystem.Money.retrieve_unsplitted_amount(ac1.funds)
    amount2 = FinancialSystem.Money.retrieve_unsplitted_amount(ac2.funds)

    assert amount1 == 10
    assert amount2 == 13.18
  end

  test "transfer_money_converting cannot transfer if not enough money available on the account" do
    currency_brl = %FinancialSystem.Currency{alph_code: "BRL", num_code: 986, decimal_points: 2}
    {:ok, money_brl1} = FinancialSystem.Money.new(20, currency_brl)
    account1 = FinancialSystem.Account.new("Allan", money_brl1)

    currency_usd = %FinancialSystem.Currency{alph_code: "USD", num_code: 840, decimal_points: 2}
    {:ok, money_brl2} = FinancialSystem.Money.new(10, currency_usd)
    account2 = FinancialSystem.Account.new("David", money_brl2)

    {resp, _response} =
      FinancialSystem.transfer_money_converting(100, 0.31825, account1, account2)

    assert resp == :error
  end
end
