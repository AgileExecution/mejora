defmodule MejoraWeb.Live.UserBoard do
  use MejoraWeb, :salad_ui_live_view
  alias Mejora.Accounts.User
  alias Mejora.Boards.Board

  def mount(_params, _session, %{assigns: assigns} = socket) do
    case assigns do
      %{current_user: nil} ->
        {:ok,
         assign(socket,
           active_members: [],
           inactive_members: [],
           boards: [],
           error: "Usuario no autenticado"
         )}

      %{current_user: current_user} ->
        case User.get_neighborhood_from_property_membership(current_user) do
          {:ok, %Mejora.Neighborhoods.Neighborhood{id: neighborhood_id}} ->
            case Board.get_boards_from_neighborhood(neighborhood_id) do
              {:ok, %{active: active_members, inactive: inactive_members, boards: boards}} ->
                socket =
                  socket
                  |> assign(:active_members, sort_members_by_role(active_members))
                  |> assign(:inactive_members, group_and_sort_inactive_members(inactive_members))
                  |> assign(:boards, boards)
                  |> assign(:error, nil)

                {:ok, socket}
            end

          {:error, _reason} ->
            {:ok,
             assign(socket,
               active_members: [],
               inactive_members: [],
               boards: [],
               error: "No se encontró vecindario"
             )}
        end
    end
  end

  defp sort_members_by_role(members) do
    role_order = %{
      "president" => 1,
      "secretary" => 2,
      "treasurer" => 3,
      "vocal_one" => 4,
      "vocal_two" => 5,
      "vocal_three" => 6
    }

    Enum.sort_by(members, fn member ->
      role =
        case member.role do
          atom when is_atom(atom) -> Atom.to_string(atom)
          string -> string
        end

      Map.get(role_order, role, 999)
    end)
  end

  defp group_and_sort_inactive_members(inactive_members) do
    inactive_members
    |> Enum.group_by(& &1.year_range)
    |> Enum.map(fn {year_range, boards} ->
      {
        year_range,
        boards
        |> Enum.group_by(& &1.board_id)
        |> Enum.map(fn {board_id, members} ->
          {board_id, sort_members_by_role(members)}
        end)
        |> Enum.into(%{})
      }
    end)
    |> Enum.into(%{})
  end
end
