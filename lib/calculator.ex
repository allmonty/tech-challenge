defmodule FinancialSystem.Calculator do
  alias FinancialSystem.Money

  def convert_currency(money, exchange_rate, currency) do
    amount = Money.retrieve_unsplitted_amount(money)
    converted_amount = amount * exchange_rate

    Money.new(converted_amount, currency)
  end
end
