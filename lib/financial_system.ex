defmodule FinancialSystem do
  @moduledoc """
  Documentation for FinancialSystem.
  """

  alias FinancialSystem.Account
  alias FinancialSystem.Calculator

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
end
