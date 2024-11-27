defmodule Mejora.Importers.Boards do
  alias Mejora.Accounts.User
  alias Mejora.Boards.{Board, BoardMembership}
  alias Mejora.Repo

  @header "Nombre de la Mesa"

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

            Enum.at(record, 0) != @header ->
              transaction_id = Ecto.UUID.generate()
              loaded_president_transaction_id = "loaded-president-#{transaction_id}"
              loaded_secretary_transaction_id = "loaded-secretary-#{transaction_id}"
              loaded_treasurer_transaction_id = "loaded-treasurer-#{transaction_id}"
              board_id = "board-#{transaction_id}"

              multi_acc
              |> load_user(record, loaded_president_transaction_id, :president)
              |> load_user(record, loaded_secretary_transaction_id, :secretary)
              |> load_user(record, loaded_treasurer_transaction_id, :treasurer)
              |> Ecto.Multi.insert(
                board_id,
                Board.changeset(%Board{}, parse_board_record(record))
              )
              |> insert_board_membership(board_id, loaded_president_transaction_id, :president)
              |> insert_board_membership(board_id, loaded_secretary_transaction_id, :secretary)
              |> insert_board_membership(board_id, loaded_treasurer_transaction_id, :treasurer)

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

  defp parse_board_record(record) do
    start_date =
      if is_integer(Enum.at(record, 1)),
        do: Timex.shift(~D[1900-01-01], days: Enum.at(record, 1)),
        else: Timex.today()

    end_date =
      if is_integer(Enum.at(record, 2)),
        do: Timex.shift(~D[1900-01-01], days: Enum.at(record, 2)),
        else: Timex.today()

    %{
      name: Enum.at(record, 0),
      start_date: start_date,
      end_date: end_date,
      status: parse_status(Enum.at(record, 13)),
      comments: Enum.at(record, 3)
    }
  end

  @user_matrix %{
    president: %{name: 4, father_last_name: 5, mother_last_name: 6},
    secretary: %{name: 7, father_last_name: 8, mother_last_name: 9},
    treasurer: %{name: 10, father_last_name: 11, mother_last_name: 12}
  }

  defp load_user(multi_acc, record, transaction_id, role) do
    Ecto.Multi.run(multi_acc, transaction_id, fn _repo, _changes ->
      name = Enum.at(record, @user_matrix[role][:name])
      father_last_name = Enum.at(record, @user_matrix[role][:father_last_name])
      mother_last_name = Enum.at(record, @user_matrix[role][:mother_last_name])

      case Repo.get_by(User,
             name: name,
             father_last_name: father_last_name,
             mother_last_name: mother_last_name
           ) do
        nil -> {:error, "User not found: #{name} #{father_last_name} #{mother_last_name}"}
        user -> {:ok, user}
      end
    end)
  end

  defp insert_board_membership(multi_acc, board_id, transaction_id, role) do
    Ecto.Multi.insert(multi_acc, Ecto.UUID.generate(), fn context ->
      board = Map.get(context, board_id, nil)
      user = Map.get(context, transaction_id, nil)

      BoardMembership.changeset(%BoardMembership{}, %{
        board_id: board.id,
        user_id: user.id,
        role: role
      })
    end)
  end

  def valid_date?(string, format \\ "{YYYY}-{0M}-{0D}") do
    case Timex.parse(string, format) do
      {:ok, _date} -> true
      {:error, _reason} -> false
    end
  end

  defp parse_status("Inactiva"), do: :inactive
  defp parse_status("Activa"), do: :active
  defp parse_status(_), do: :inactive
end
