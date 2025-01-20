defmodule Mejora.Transactions.Transaction do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias Mejora.Transactions.TransactionRow
  alias __MODULE__, as: Transaction

  @required_fields [
    :total_amount,
    :transaction_type,
    :payment_date,
    :association_id,
    :association_type
  ]

  schema "transactions" do
    field :total_amount, :decimal
    field :author, :string
    field :transaction_type, Ecto.Enum, values: [:income, :outcome, :other]
    field :payment_date, :utc_datetime
    field :comments, :string
    field :association_id, :integer
    field :association_type, :string
    field :date_range, :map, virtual: true
    field :index, :integer, virtual: true

    has_many :transaction_rows, TransactionRow

    timestamps()
  end

  def changeset(transaction, attrs) do
    fields = __schema__(:fields)

    transaction
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:transaction_rows, with: &TransactionRow.changeset/2)
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Transaction{}
    |> cast(attrs, fields)
    |> cast_assoc(:transaction_rows, with: &TransactionRow.changeset/2)
  end

  def parse_record(record) do
    if Enum.at(record, 5) == :outcome,
      do: do_parse_outcome(record),
      else: do_parse_income(record)
  end

  defp do_parse_income(record) do
    property =
      [street: Enum.at(record, 0), number: Enum.at(record, 1)]
      |> Mejora.Properties.get_properties()
      |> List.first()
      |> maybe_nil_record()

    date = parse_datetime(Enum.at(record, 2))

    %{
      payment_date: date,
      comments: Enum.at(record, 3),
      transaction_type: Enum.at(record, 5),
      total_amount: Enum.at(record, 4),
      association_id: Map.get(property, :id),
      association_type: "Property",
      transaction_rows: [
        %{
          amount: Enum.at(record, 4),
          date: date
        }
      ]
    }
  end

  defp do_parse_outcome(record) do
    IO.inspect(record)
    neighborhood = Mejora.Repo.get_by(Mejora.Neighborhoods.Neighborhood, name: Enum.at(record, 4))
    date = parse_datetime(Enum.at(record, 0))

    %{
      payment_date: date,
      comments: Enum.at(record, 3),
      transaction_type: Enum.at(record, 5),
      total_amount: Enum.at(record, 2),
      association_id: Map.get(neighborhood, :id),
      association_type: "Neighborhood",
      transaction_rows: [
        %{
          amount: Enum.at(record, 2),
          date: date
        }
      ]
    }
  end

  defp maybe_nil_record(nil), do: %{}
  defp maybe_nil_record(record), do: record
end
