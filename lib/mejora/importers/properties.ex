defmodule Mejora.Importers.Properties do
  import Mejora.Importers

  alias Mejora.Properties.Property
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
                Property.changeset(%Property{}, parse_record(record))
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
          IO.puts("Failed to insert Property:")
          IO.inspect(failed_operation)
          IO.inspect(failed_value)
          IO.inspect(changes_so_far)
      end
    end)
  end

  defp parse_record(record) do
    %{
      street: Enum.at(record, 0),
      number: parse_number(Enum.at(record, 1)),
      comments: Enum.at(record, 3),
      status: parse_status(Enum.at(record, 2))
    }
  end

  defp parse_status("Activa"), do: :active
  defp parse_status("Inactiva"), do: :inactive
end
