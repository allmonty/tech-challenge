defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  alias FinancialSystem.Account
  alias FinancialSystem.Calculator
  alias FinancialSystem.Money

  def transfer_money(amount, %Account{funds: from_money} = from, %Account{funds: to_money} = to) do
    with true <- from.funds.currency.num_code == to.funds.currency.num_code,
         {:ok, subtracted_from_money} <- Calculator.subtract(from_money, amount),
         {:ok, summed_to_money} <- Calculator.sum(to_money, amount) do
      {:ok,
       %{
         from: %Account{from | funds: subtracted_from_money},
         to: %Account{to | funds: summed_to_money}
       }}
    else
      false -> {:error, "Different currency accounts"}
      {:error, resp} -> {:error, %{response: resp, account_from: from, account_to: to}}
    end
  end

  def transfer_money_converting(
        amount,
        exchange_rate,
        %Account{funds: from_money} = from,
        %Account{funds: to_money} = to
      ) do
    with true <- from.funds.currency.num_code != to.funds.currency.num_code,
         {:ok, subtracted_from_money} <- Calculator.subtract(from_money, amount),
         {:ok, exchanged_amount_money} <-
           Calculator.convert_currency(amount, exchange_rate, from.funds.currency),
         exchanged_amount <- Money.retrieve_unsplitted_amount(exchanged_amount_money),
         {:ok, summed_to_money} <- Calculator.sum(to_money, exchanged_amount) do
      {:ok,
       %{
         from: %Account{from | funds: subtracted_from_money},
         to: %Account{to | funds: summed_to_money}
       }}
    else
      false -> {:error, "Different currency accounts"}
      {:error, resp} -> {:error, %{response: resp, account_from: from, account_to: to}}
    end
  end
end
