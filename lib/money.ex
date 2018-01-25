defmodule FinancialSystem.Money do
  defstruct currency: nil, int_part: nil, dec_part: nil

  def new(amount, alph_code, num_code, decimal_points) do
    with {:ok, alph_code} <- is_valid_alph_code(alph_code),
         {:ok, num_code} <- is_valid_num_code(num_code),
         {:ok, decimal_points} <- is_valid_integer(decimal_points),
         {:ok, decimal_points} <- is_positive_number(decimal_points),
         {:ok, amount} <- is_valid_number(amount),
         {:ok, amount} <- is_positive_number(amount),
         {:ok, {int_part, dec_part}} <- split_number_in_two_integers(amount) do
      {:ok,
       %FinancialSystem.Money{
         currency: %FinancialSystem.Currency{
           alph_code: alph_code,
           num_code: num_code,
           decimal_points: decimal_points
         },
         dec_part: dec_part,
         int_part: int_part
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def retrieve_unsplitted_amount(%FinancialSystem.Money{
        int_part: int_part,
        dec_part: dec_part,
        currency: %FinancialSystem.Currency{decimal_points: dec_points}
      }) do
    {number, _rest} = Float.parse("#{int_part}.#{dec_part}")
    Float.round(number, dec_points)
  end

  defp is_valid_integer(number) do
    cond do
      is_integer(number) ->
        {:ok, number}

      true ->
        {:error, "Not a valid integer : #{number}"}
    end
  end

  defp is_valid_number(number) do
    cond do
      is_integer(number) ->
        {:ok, number}

      is_float(number) ->
        {:ok, number}

      true ->
        {:error, "Not a valid number : #{number}"}
    end
  end

  defp is_positive_number(number) do
    cond do
      number >= 0 ->
        {:ok, number}

      number < 0 ->
        {:error, "Money amount can't be negative : #{number}"}

      true ->
        {:error, "Given number is invalid : #{number}"}
    end
  end

  defp is_valid_num_code(num_code) do
    if is_integer(num_code) and num_code >= 0 and num_code < 1000 do
      {:ok, num_code}
    else
      {:error, "Invalid numeric code : #{num_code}"}
    end
  end

  defp is_valid_alph_code(alph_code) do
    if is_binary(alph_code) and String.length(alph_code) == 3 do
      {:ok, alph_code}
    else
      {:error, "Invalid alphabetic code : #{alph_code}"}
    end
  end

  defp split_number_in_two_integers(number) when is_float(number) do
    with number <- Float.to_string(number),
         {int_part, rest} <- Integer.parse(number),
         rest <- String.trim(rest, "."),
         {dec_part, _rest} <- Integer.parse(rest) do
      {:ok, {int_part, dec_part}}
    else
      :error -> {:error, "Couldnt split number into integers : #{number}"}
    end
  end

  defp split_number_in_two_integers(number) when is_integer(number) do
    {:ok, {number, 0}}
  end
end
