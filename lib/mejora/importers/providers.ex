defmodule Mejora.Importers.Providers do
  import Mejora.Importers

  alias Mejora.Providers.Provider
  alias Mejora.Repo

  def process(tab) do
    tab
    |> Xlsxir.get_list()
    |> Stream.map(& &1)
    |> Stream.chunk_every(100)
    |> Enum.each(fn chunk ->
      multi =
        Enum.reduce(chunk, Ecto.Multi.new(), fn record, multi_acc ->
          cond do
            is_nil(Enum.at(record, 0)) ->
              multi_acc

            Enum.at(record, 0) != "Calle" ->
              Ecto.Multi.insert(
                multi_acc,
                Ecto.UUID.generate(),
                Provider.changeset(%Provider{}, parse_record(record))
              )

            true ->
              multi_acc
          end
        end)

      case Repo.transaction(multi) do
        {:ok, _result} ->
          Xlsxir.close(tab)

        {:error, failed_operation, failed_value, changes_so_far} ->
          Xlsxir.close(tab)
          IO.puts("Failed to insert Provider:")
          IO.inspect(failed_operation)
          IO.inspect(failed_value)
          IO.inspect(changes_so_far)
      end
    end)
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 0),
      legal_name: Enum.at(record, 1),
      rfc: parse_string(Enum.at(record, 2)),
      address: Enum.at(record, 3),
      bank_account: parse_number(Enum.at(record, 4)),
      description: Enum.at(record, 5)
    }
  end
end
