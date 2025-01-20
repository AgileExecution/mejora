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
  def parse_date({year, month, day} = value), do: Timex.to_date(value)
  def parse_date(value) when is_bitstring(value), do: Timex.shift(Timex.now(), months: 12)
  def parse_date(value) when is_integer(value), do: Timex.shift(~D[1900-01-01], days: value)

  def parse_datetime(nil), do: nil
  def parse_datetime({_year, _month, _day} = value), do: Timex.to_datetime(value)

  def generate_monthly_dates(start_date, end_date) do
    Stream.unfold(start_date, fn current_date ->
      if current_date <= end_date do
        next_date = Date.add(current_date, days_until_next_month(current_date))
        {current_date, next_date}
      else
        nil
      end
    end)
    |> Enum.to_list()
  end

  defp days_until_next_month(date) do
    {_, days_in_month} = Date.month_and_year(date)
    days_in_month - date.day + 1
  end
end
