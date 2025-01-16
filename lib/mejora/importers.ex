defmodule Mejora.Importers do
  alias Ecto.Adapter.Transaction
  alias Mejora.Accounts.User
  alias Mejora.Boards.Board
  alias Mejora.Neighborhoods.Neighborhood
  alias Mejora.Properties.Property
  alias Mejora.Providers.Provider
  alias Mejora.Importers.SpreadsheetErrors
  alias Mejora.Repo
  alias Mejora.Transactions.Transaction

  def import_stream!(stream, opts \\ [truncate: false]) do
    if Keyword.get(opts, :truncate, false), do: do_truncate()

    Repo.transaction(fn ->
      # Process each worksheet
      stream
      |> Stream.filter(fn
        {:properties, data} ->
          IO.inspect(data)
          true

        _ ->
          false
      end)
      |> Stream.map(fn {worksheet_name, data} ->
        # Process each row of the current worksheet
        schema = get_schema(worksheet_name)

        data
        |> Enum.filter(fn
          {%{nil => nil}, _index} -> false
          {%{nil => _}, _index} -> false
          _ -> true
        end)
        |> Stream.map(&schema.embedded_changeset/1)
      end)
      |> Stream.flat_map(fn inner_stream -> inner_stream end)
      |> Enum.reduce(%{valid: [], errors: struct(SpreadsheetErrors)}, &accumulate_results/2)
      |> handle_results()
    end)
  end

  defp accumulate_results(%{valid?: true} = changeset, acc),
    do: %{valid: [Ecto.Changeset.apply_changes(changeset) | acc.valid], errors: acc.errors}

  defp accumulate_results(changeset, acc),
    do: %{valid: acc.valid, errors: process_errors(changeset, acc.errors)}

  defp handle_results(%{
         valid: valid_records,
         errors: %SpreadsheetErrors{global: global, rows: rows}
       })
       when global == [] and rows == %{} do
    Enum.each(valid_records, &create_record(&1))
    valid_records
  end

  defp handle_results(%{errors: errors}) do
    IO.inspect(errors)
    Repo.rollback(errors)
  end

  defp process_errors(
         %Ecto.Changeset{changes: data, errors: errors} = _changeset,
         spreadsheet_errors
       ) do
    error_message = Mejora.Ecto.Helpers.translate_errors_to_string(errors)
    SpreadsheetErrors.add_row_error(spreadsheet_errors, data.index, error_message)
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

  defp get_schema(:providers), do: Provider
  defp get_schema(:boards), do: Board
  defp get_schema(:properties), do: Property
  defp get_schema(:neighborhoods), do: Neighborhood
  defp get_schema(:people), do: User
  defp get_schema(:income_transactions), do: Transaction
  defp get_schema(:outcome_transactions), do: Transaction
  defp get_schema(:people_old), do: User
  defp get_schema(:quotas), do: Transaction

  defp create_record(record), do: Repo.insert(record)
end
