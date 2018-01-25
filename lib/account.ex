defmodule FinancialSystem.Account do
  defstruct name: nil, funds: nil

  alias FinancialSystem.Money

  def new(name, %Money{} = funds) do
    %FinancialSystem.Account{name: name, funds: funds}
  end
end
