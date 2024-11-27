defmodule Mejora.Importers do
  alias Mejora.Importers.{Boards, Neighborhoods, People, Properties, Providers, Transactions}

  def process_spreadsheet(file_path, opts \\ [truncate: false]) do
    if Keyword.get(opts, :truncate, false), do: do_truncate()

    case Xlsxir.multi_extract(file_path) do
      [
        {:ok, neighborhoods},
        {:ok, boards},
        {:ok, properties},
        {:ok, _people},
        {:ok, people},
        {:ok, providers},
        {:ok, income_transactions},
        {:ok, outcome_transactions}
        | _
      ] ->
        Providers.process(providers)
        Neighborhoods.process(neighborhoods)
        Properties.process(properties)
        People.process(people)
        Boards.process(boards)
        Transactions.process(income_transactions)
        Transactions.process(outcome_transactions)

      {:error, reason} ->
        IO.inspect(reason)
    end
  end

  def parse_number(nil), do: ""
  def parse_number(number) when is_bitstring(number), do: number
  def parse_number(number) when is_integer(number), do: Integer.to_string(number)

  def parse_number(number) when is_float(number),
    do: number |> round() |> Integer.to_string()

  def parse_string(nil), do: ""
  def parse_string(string) when is_bitstring(string), do: string
  def parse_string(string) when is_integer(string), do: Integer.to_string(string)
  def parse_string(string) when is_float(string), do: Float.to_string(string)

  def do_truncate do
    ["neighborhoods", "properties", "users", "boards", "providers", "transactions"]
    |> Enum.each(fn table ->
      case Mejora.Repo.query("TRUNCATE TABLE #{table} CASCADE") do
        {:ok, _result} ->
          IO.puts("#{table} table truncated successfully.")

        {:error, reason} ->
          IO.puts("Failed to truncate #{table} table: #{inspect(reason)}")
      end
    end)
  end
end
