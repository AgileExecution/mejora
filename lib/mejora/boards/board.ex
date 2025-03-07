defmodule Mejora.Boards.Board do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Mejora.Utils

  alias Mejora.Repo
  alias Mejora.Boards.Board
  alias Mejora.Boards.BoardMembership
  alias Mejora.Accounts.User

  @required_fields [:name, :start_date, :end_date, :status]

  schema "boards" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string
    field :index, :integer, virtual: true

    belongs_to :neighborhood, Mejora.Neighborhoods.Neighborhood

    timestamps()
  end

  def changeset(board, attrs) do
    board
    |> cast(attrs, __schema__(:fields))
    |> validate_required(@required_fields)
  end

  def get_boards_from_neighborhood(neighborhood_id) do
    boards_query =
      from b in Board,
        where: b.neighborhood_id == ^neighborhood_id,
        select: %{
          id: b.id,
          name: b.name,
          start_date: b.start_date,
          end_date: b.end_date,
          status: b.status
        }

    boards = Repo.all(boards_query)

    {active_boards, inactive_boards} =
      Enum.split_with(boards, fn board -> board.status == :active end)

    active_members = get_board_members(active_boards)
    inactive_members = get_board_members(inactive_boards)

    {:ok, %{active: active_members, inactive: inactive_members, boards: boards}}
  end

  defp get_board_members(boards) do
    board_ids = Enum.map(boards, & &1.id)

    if board_ids == [] do
      []
    else
      memberships_query =
        from bm in BoardMembership,
          where: bm.board_id in ^board_ids,
          select: %{board_id: bm.board_id, user_id: bm.user_id, role: bm.role}

      memberships = Repo.all(memberships_query)

      user_ids = Enum.map(memberships, & &1.user_id)

      users_query =
        from u in User,
          where: u.id in ^user_ids,
          select: %{
            id: u.id,
            name: u.name,
            father_last_name: u.father_last_name,
            mother_last_name: u.mother_last_name
          }

      users = Repo.all(users_query)
      users_map = Map.new(users, &{&1.id, &1})

      Enum.map(memberships, fn %{board_id: board_id, user_id: user_id, role: role} ->
        board = Enum.find(boards, &(&1.id == board_id))

        year_range =
          if board.start_date && board.end_date do
            "#{board.start_date.year}-#{board.end_date.year}"
          else
            "Sin Fecha"
          end

        user =
          Map.get(users_map, user_id, %{
            name: "Desconocido",
            father_last_name: "",
            mother_last_name: ""
          })

        full_name = "#{user.name} #{user.father_last_name} #{user.mother_last_name}"

        %{
          board_id: board_id,
          role: role,
          name: full_name |> String.trim(),
          year_range: year_range
        }
      end)
    end
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Board{}
    |> cast(attrs, fields)
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 0),
      start_date: parse_date(Enum.at(record, 1)),
      end_date: parse_date(Enum.at(record, 2)),
      comments: Enum.at(record, 3),
      status: parse_status(Enum.at(record, 4)),
      neighborhood_id: Enum.at(record, 5)
    }
  end
end
