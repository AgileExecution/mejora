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
    field :index, :integer, virtual: true

    belongs_to :neighborhood, Mejora.Neighborhoods.Neighborhood

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
      comments: Enum.at(record, 3),
      status: parse_status(Enum.at(record, 4)),
      neighborhood_id: Enum.at(record, 5)
    }
  end
end
