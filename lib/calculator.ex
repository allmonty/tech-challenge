defmodule FinancialSystem.Calculator do
  alias FinancialSystem.Money

  def convert_currency(%Money{} = money, exchange_rate, currency) do
    amount = Money.retrieve_unsplitted_amount(money)
    convert_currency(amount, exchange_rate, currency)
  end

  def convert_currency(amount, exchange_rate, currency) do
    converted_amount = amount * exchange_rate

    Money.new(converted_amount, currency)
  end

  def sum(%Money{} = money, %Money{} = amount) do
    retrieved_amount = Money.retrieve_unsplitted_amount(amount)
    sum(money, retrieved_amount)
  end

  def sum(%Money{} = money, amount) do
    money_amount = Money.retrieve_unsplitted_amount(money)
    Money.new(money_amount + amount, money.currency)
  end

  def subtract(%Money{} = money, %Money{} = amount) do
    retrieved_amount = Money.retrieve_unsplitted_amount(amount)
    subtract(money, retrieved_amount)
  end

  def subtract(money, amount) do
    cond do
      amount >= 0 ->
        money_amount = Money.retrieve_unsplitted_amount(money)
        Money.new(money_amount - amount, money.currency)

      true ->
        {:error, "Should not subtract a negative number"}
    end
  end
end
