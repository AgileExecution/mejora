defmodule Mejora.Importer do
  alias Ecto.Adapter.Transaction

  alias Mejora.{
    Accounts.User,
    Boards.Board,
    Neighborhoods.Neighborhood,
    Properties.Property,
    Providers.Provider,
    Importer.SpreadsheetErrors,
    Repo,
    Transactions.Transaction
  }

  def extract_data(path) do
    path
    |> Xlsxir.multi_extract()
    |> Enum.with_index()
    |> Enum.map(fn {{:ok, worksheet_id}, worksheet_index} ->
      worksheet_id
      |> Xlsxir.get_list()
      |> then(fn [_header_names | data] ->
        case get_worksheet_name(worksheet_index) do
          :income_transactions ->
            Enum.map(data, fn row ->
              row ++ [:income]
            end)

          :outcome_transactions ->
            Enum.map(data, fn row ->
              row ++ [:outcome]
            end)

          _ ->
            data
        end
      end)
      |> then(fn data ->
        {get_worksheet_name(worksheet_index), data}
      end)
    end)
  end

  defp get_worksheet_name(0), do: :neighborhoods
  defp get_worksheet_name(1), do: :boards
  defp get_worksheet_name(2), do: :properties
  defp get_worksheet_name(3), do: :people_old
  defp get_worksheet_name(4), do: :people
  defp get_worksheet_name(5), do: :providers
  defp get_worksheet_name(6), do: :income_transactions
  defp get_worksheet_name(7), do: :outcome_transactions
  defp get_worksheet_name(8), do: :quotas
  defp get_worksheet_name(_), do: :unknown

  def import_stream([content], opts \\ [truncate: false]) do
    if Keyword.get(opts, :truncate, false), do: do_truncate()

    order = [
      :boards,
      :neighborhoods,
      :quotas,
      :properties,
      :people,
      :providers,
      :income_transactions,
      :outcome_transactions,
      :people_old
    ]

    Repo.transaction(fn ->
      # Process each worksheet
      content
      |> Enum.sort_by(&Enum.find_index(order, fn table -> table == &1 end))
      |> Stream.filter(fn
        {:people_old, _data} ->
          false

        {:income_transactions, _data} ->
          false

        {:outcome_transactions, _data} ->
          false

        _ ->
          true
      end)
      |> Stream.map(fn {worksheet_name, data} ->
        # Process each row of the current worksheet
        schema = get_schema(worksheet_name)

        data
        |> Stream.with_index()
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
  defp get_schema(:quotas), do: Quota

  defp create_record(record), do: Repo.insert(record)
end
