defmodule Mejora.Importer.SpreadsheetErrors do
  alias __MODULE__, as: SpreadsheetErrors

  @type t :: %SpreadsheetErrors{global: list(), rows: map()}

  defstruct global: [], rows: %{}

  def error_length(%SpreadsheetErrors{global: global_errors, rows: row_errors}),
    do: length(global_errors) + map_size(row_errors)

  def error_length(nil), do: 0

  def to_list(%SpreadsheetErrors{global: global_errors, rows: row_errors}),
    do: global_errors ++ (Enum.sort(row_errors) |> Enum.map(&print_row/1))

  def add_global_error(%SpreadsheetErrors{global: global_errors} = errors, error),
    do: %{errors | global: Enum.uniq([error | global_errors])}

  def add_row_error(%SpreadsheetErrors{rows: row_errors} = errors, index, error, worksheet_name)
      when is_binary(error) and byte_size(error) > 0,
      do: %{
        errors
        | rows:
            Map.update(
              row_errors,
              index,
              to_string(error),
              &"#{String.slice(&1, 0..-2//1)}; #{to_string(error)}."
            )
      }

  def add_row_error(%SpreadsheetErrors{} = errors, _index, _error, _worksheet_name), do: errors

  defp print_row({error_index, row_error}),
    do: "Row #{to_string(error_index)}: #{to_string(row_error)}"
end
