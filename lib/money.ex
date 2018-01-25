defmodule FinancialSystem.Money do
  defstruct code: nil, decimal_points: nil, int_part: nil, dec_part: nil

  def new(amount, code, decimal_points) do
    with {:ok, code} <- is_valid_code(code),
         {:ok, decimal_points} <- is_valid_integer(decimal_points),
         {:ok, decimal_points} <- is_positive_number(decimal_points),
         {:ok, amount} <- is_valid_number(amount),
         {:ok, amount} <- is_positive_number(amount),
         {:ok, {int_part, dec_part}} <- split_number_in_two_integers(amount) do
      {:ok, %FinancialSystem.Money{code: code, int_part: int_part, dec_part: dec_part, decimal_points: decimal_points}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp is_valid_integer(number) do
    cond do
      is_integer(number) ->
        {:ok, number}

      true ->
        {:error, "Not a valid integer"}
    end
  end

  defp is_valid_number(number) do
    cond do
      is_integer(number) ->
        {:ok, number}

      is_float(number) ->
        {:ok, number}

      true ->
        {:error, "Not a valid number"}
    end
  end

  defp is_positive_number(number) do
    cond do
      number >= 0 ->
        {:ok, number}

      number < 0 ->
        {:error, "Money amount can't be negative"}

      true ->
        {:error, "Given number is invalid"}
    end
  end

  defp is_valid_code(code) do
    if is_binary(code) and String.length(code) == 3 do
      {:ok, code}
    else
      {:error, "Invalid code"}
    end
  end

  defp split_number_in_two_integers(number) when is_float(number) do
    with number <- Float.to_string(number),
         {int_part, rest} <- Integer.parse(number),
         rest <- String.trim(rest, "."),
         {dec_part, _rest} <- Integer.parse(rest) do
      {:ok, {int_part, dec_part}}
    else
      :error -> {:error, "Couldnt split number into integers"}
    end
  end

  defp split_number_in_two_integers(number) when is_integer(number) do
    {:ok, {number, 0}}
  end
end
