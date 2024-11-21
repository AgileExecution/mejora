defmodule Mejora.Importers.Neighborhoods do
  import Mejora.Importers

  alias Mejora.Neighborhoods.Neighborhood
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

            Enum.at(record, 0) != "Nombre de la Colonia" ->
              Ecto.Multi.insert(
                multi_acc,
                Ecto.UUID.generate(),
                Neighborhood.changeset(%Neighborhood{}, parse_record(record))
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
          IO.puts("Failed to insert:")
          IO.inspect(failed_operation)
          IO.inspect(failed_value)
          IO.inspect(changes_so_far)
      end
    end)
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 0),
      commercial_name: Enum.at(record, 0),
      type: Enum.at(record, 1),
      state: Enum.at(record, 3),
      city: Enum.at(record, 4),
      zipcode: parse_number(Enum.at(record, 5)),
      email: Enum.at(record, 6)
    }
  end
end
