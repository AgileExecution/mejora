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
              loaded_treasure_transaction_id = "loaded-treasure-#{transaction_id}"
              board_id = "board-#{transaction_id}"

              multi_acc
              |> load_user(record, loaded_president_transaction_id)
              |> load_user(record, loaded_secretary_transaction_id)
              |> load_user(record, loaded_treasure_transaction_id)
              |> Ecto.Multi.insert(
                board_id,
                Board.changeset(%Board{}, parse_board_record(record))
              )
              |> insert_board_membership(board_id, loaded_president_transaction_id, :president)
              |> insert_board_membership(board_id, loaded_secretary_transaction_id, :secretary)
              |> insert_board_membership(board_id, loaded_treasure_transaction_id, :treasure)

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
    %{
      name: Enum.at(record, 0),
      start_date: Enum.at(record, 1),
      end_date: Enum.at(record, 2),
      status: Enum.at(record, 4),
      comments: Enum.at(record, 3)
    }
  end

  defp load_user(multi_acc, _record, transaction_id) do
    Ecto.Multi.run(multi_acc, transaction_id, fn _repo, _changes ->
      name = ""
      father_last_name = ""
      mother_last_name = ""

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
end
