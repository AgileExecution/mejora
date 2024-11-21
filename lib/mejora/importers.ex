defmodule Mejora.Importers do
  def parse_number(nil), do: ""
  def parse_number(number) when is_bitstring(number), do: number
  def parse_number(number) when is_integer(number), do: Integer.to_string(number)

  def parse_number(number) when is_float(number),
    do: number |> round() |> Integer.to_string()
end
