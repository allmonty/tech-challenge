defmodule FinancialSystem.Money do
  defstruct code: nil, decimal_points: nil, int_part: nil, dec_part: nil

  def new(amount, _code, _decimal_points) when is_float(amount) do
    case split_float_in_two_integers(amount) do
      {:ok, {int_part, dec_part}} ->
        {:ok, %FinancialSystem.Money{int_part: int_part, dec_part: dec_part}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp split_float_in_two_integers(amount) do
    with number <- Float.to_string(amount),
         {int_part, rest} <- Integer.parse(number),
         rest <- String.trim(rest, "."),
         {dec_part, _rest} <- Integer.parse(rest) do
      {:ok, {int_part, dec_part}}
    else
      :error -> {:error, "Couldnt split amount into integers"}
    end
  end
end
