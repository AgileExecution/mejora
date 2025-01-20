defmodule Mejora.Neighborhoods.Quota do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias __MODULE__, as: Quota
  alias Mejora.Neighborhoods.Neighborhood

  schema "quotas" do
    field :amount, :decimal
    field :start_date, :date
    field :end_date, :date
    field :comments, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :index, :integer, virtual: true

    belongs_to :neighborhood, Neighborhood

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:amount, :start_date, :end_date, :neighborhood_id])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Quota{}
    |> cast(attrs, fields)
  end

  defp parse_record(record) do
    %{
      amount: parse_number(Enum.at(record, 0)),
      start_date: parse_date(Enum.at(record, 1)),
      end_date: parse_date(Enum.at(record, 2)),
      comments: Enum.at(record, 4),
      status: parse_status(Enum.at(record, 3)),
      neighborhood_id: Enum.at(record, 5)
    }
  end
end
