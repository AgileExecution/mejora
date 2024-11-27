defmodule Mejora.Importers.People do
  import Mejora.Importers

  alias Mejora.Accounts.User
  alias Mejora.Properties.{Property, PropertyMembership}
  alias Mejora.Repo

  @header "Propiedad"

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

            is_nil(Enum.at(record, 5)) or String.length(Enum.at(record, 5)) == 0 ->
              multi_acc

            Enum.at(record, 0) != @header ->
              transaction_id = Ecto.UUID.generate()
              user_transaction_id = "user-#{transaction_id}"
              street = Enum.at(record, 1)
              number = record |> Enum.at(2) |> parse_number() |> parse_string()
              loaded_property_id = "loaded-property-#{transaction_id}"

              multi_acc
              |> Ecto.Multi.run(loaded_property_id, fn _repo, _changes ->
                case Repo.get_by(Property, street: street, number: number) do
                  nil -> {:error, "Property not found: #{street} #{number}"}
                  property -> {:ok, property}
                end
              end)
              |> Ecto.Multi.insert(
                user_transaction_id,
                User.person_changeset(%User{}, parse_record(record))
              )
              |> Ecto.Multi.insert(Ecto.UUID.generate(), fn context ->
                property = Map.get(context, loaded_property_id, nil)
                user = Map.get(context, user_transaction_id, nil)

                PropertyMembership.changeset(%PropertyMembership{}, %{
                  property_id: property.id,
                  user_id: user.id,
                  role: :resident
                })
              end)

            true ->
              multi_acc
          end
        end)

      case Repo.transaction(multi) do
        {:ok, _result} ->
          Xlsxir.close(tab)

        {:error, failed_operation, failed_value, changes_so_far} ->
          Xlsxir.close(tab)
          IO.puts("Failed to insert Person:")
          IO.inspect(failed_operation)
          IO.inspect(failed_value)
          IO.inspect(changes_so_far)
      end
    end)
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 6),
      father_last_name: Enum.at(record, 7),
      mother_last_name: Enum.at(record, 8),
      curp: Enum.at(record, 9),
      rfc: Enum.at(record, 10),
      email: Enum.at(record, 5),
      hashed_password: Bcrypt.hash_pwd_salt("changeme"),
      cellphone_number: record |> Enum.at(4) |> parse_number() |> parse_string(),
      confirmed_at: DateTime.utc_now()
    }
  end
end
