defmodule Mejora.Utils do
  def parse_status("Activa"), do: :active
  def parse_status("Activo"), do: :active
  def parse_status("Inactiva"), do: :inactive
  def parse_status("Inactivo"), do: :inactive
  def parse_status(_), do: :inactive

  def parse_number(nil), do: ""
  def parse_number(number) when is_bitstring(number), do: number
  def parse_number(number) when is_integer(number), do: Integer.to_string(number)

  def parse_number(number) when is_float(number),
    do: number |> round() |> Integer.to_string()

  def parse_string(nil), do: ""
  def parse_string(string) when is_bitstring(string), do: string
  def parse_string(string) when is_integer(string), do: Integer.to_string(string)
  def parse_string(string) when is_float(string), do: Float.to_string(string)

  def parse_date(nil), do: nil
  def parse_date({_year, _month, _day} = value), do: Timex.to_date(value)
  def parse_date(value) when is_bitstring(value), do: Timex.shift(Timex.now(), months: 12)
  def parse_date(value) when is_integer(value), do: Timex.shift(~D[1900-01-01], days: value)
  def parse_date(value), do: value

  def parse_datetime(nil), do: nil
  def parse_datetime({_year, _month, _day} = value), do: Timex.to_datetime(value)
end
