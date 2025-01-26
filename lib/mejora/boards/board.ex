defmodule Mejora.Boards.Board do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias __MODULE__, as: Board

  @required_fields [:name, :start_date, :end_date, :status]

  schema "boards" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string
    field  :neighborhood_id, :integer
    field :index, :integer, virtual: true

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
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
      status: parse_status(Enum.at(record, 13)),
      comments: Enum.at(record, 3)
    }
  end
end
