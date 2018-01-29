defmodule FinancialSystem do
  @moduledoc """
    Provides methods for money tranferences
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

  @doc """
    Splits the bill between multiple accounts.
    Receives the receiver account, the amount of money to be paid and an array with the accounts and
    a number representing the number of parts that will be discunted of that account.
    `accounts = [{part_number, %Account{}}, ...]`
  """
  def payment_splitting_money_in_parts(
        %Account{} = receiver,
        %Money{} = amount,
        accounts_and_parts
      ) do
    money_per_part = calculate_money_per_part(amount, accounts_and_parts)

    result =
      calculate_parts_from_accounts(money_per_part, accounts_and_parts, &Calculator.subtract/2)

    case result do
      {:error, resp} ->
        {:error, "Payment splitment couldn't be done: #{resp}"}

      {:ok, result} ->
        case Calculator.sum(receiver.funds, amount) do
          {:error, resp} ->
            {:error, "Receiver account problem: #{resp}"}

          {:ok, money} ->
            new_receiver_account = %Account{receiver | funds: money}
            {:ok, %{receiver: new_receiver_account, payers: result}}
        end
    end
  end

  @doc """
    Transfer amount to multiple accounts.
    Receives the origin account, the amount of money to be tranfered and an array with the accounts and
    a number representing the number of parts that will be received by each account.
    `accounts = [{part_number, %Account{}}, ...]`
  """
  def transfer_splitting_money_in_parts(
        %Account{} = origin,
        %Money{} = amount,
        accounts_and_parts
      ) do
    money_per_part = calculate_money_per_part(amount, accounts_and_parts)

    result = calculate_parts_from_accounts(money_per_part, accounts_and_parts, &Calculator.sum/2)

    case result do
      {:error, resp} ->
        {:error, "Tranfer with splitment couldn't be done: #{resp}"}

      {:ok, result} ->
        case Calculator.subtract(origin.funds, amount) do
          {:error, resp} ->
            {:error, "Origin account problem: #{resp}"}

          {:ok, money} ->
            new_origin_account = %Account{origin | funds: money}
            {:ok, %{origin: new_origin_account, payers: result}}
        end
    end
  end

  defp calculate_money_per_part(%Money{} = amount, accounts_and_parts) do
    Enum.map(accounts_and_parts, fn {part, _account} -> part end)
    |> Enum.sum()
    |> divide_per_parts(Money.retrieve_unsplitted_amount(amount))
  end

  defp divide_per_parts(num_of_parts, amount) do
    amount / num_of_parts
  end

  defp calculate_parts_from_accounts(money_per_part, accounts_and_parts, calc) do
    result =
      Enum.map(accounts_and_parts, fn {part, account} ->
        case calc.(account.funds, money_per_part * part) do
          {:ok, result_money} ->
            {:ok, %Account{account | funds: result_money}}

          {:error, response} ->
            {:error, response}
        end
      end)

    case Enum.find(result, fn {code, _} -> code == :error end) do
      nil ->
        {:ok, Enum.map(result, fn {:ok, account} -> account end)}

      {:error, resp} ->
        {:error, resp}
    end
  end
end
