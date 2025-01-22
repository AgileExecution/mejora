defmodule Mejora.Transactions.Invoice do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias Ecto.Adapter.Transaction
  alias Mejora.Neighborhoods.Neighborhood
  alias Mejora.Transactions.Transaction

  alias __MODULE__, as: Invoice

  schema "invoices" do
    field :transaction_type, Ecto.Enum, values: [:sale, :purchase, :other]
    field :due_date, :date
    field :invoice_number, :string
    field :total, :decimal
    field :status, Ecto.Enum, values: [:unpaid, :pending, :paid, :cancelled]
    field :comments, :string
    field :metadata, :map
    field :property_id, :integer
    field :index, :integer, virtual: true

    belongs_to :neighborhood, Neighborhood
    has_many :transactions, Transaction

    timestamps()
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Invoice{}
    |> cast(attrs, fields)
    |> cast_assoc(:transactions, with: &Transaction.changeset/2)
  end

  def parse_record(record) do
    if Enum.at(record, 5) == :sale,
      do: do_parse_sale(record),
      else: do_parse_purchase(record)
  end

  defp do_parse_sale(record) do
    property =
      [street: Enum.at(record, 0), number: Enum.at(record, 1)]
      |> Mejora.Properties.get_properties()
      |> List.first()
      |> maybe_nil_record()

    neighborhood =
      Mejora.Neighborhoods.Neighborhood
      |> Mejora.Repo.get_by(name: Enum.at(record, 4))
      |> maybe_nil_record()

    date = parse_datetime(Enum.at(record, 2))

    %{
      status: :paid,
      due_date: date,
      comments: Enum.at(record, 3),
      transaction_type: :sale,
      total: Enum.at(record, 4),
      property_id: property.id,
      neighborhood_id: neighborhood.id,
      transactions: [
        %{
          total_amount: Enum.at(record, 4),
          payment_date: date,
          comments: Enum.at(record, 3),
          transaction_rows: [
            %{
              amount: Enum.at(record, 4),
              date: date
            }
          ]
        }
      ]
    }
  end

  defp do_parse_purchase(record) do
    neighborhood = Mejora.Repo.get_by(Mejora.Neighborhoods.Neighborhood, name: Enum.at(record, 4))
    date = parse_datetime(Enum.at(record, 0))

    %{
      status: :paid,
      due_date: date,
      comments: Enum.at(record, 3),
      transaction_type: :sale,
      total: Enum.at(record, 2),
      neighborhood_id: neighborhood.id,
      transactions: [
        %{
          total_amount: Enum.at(record, 2),
          payment_date: date,
          comments: Enum.at(record, 3),
          transaction_rows: [
            %{
              amount: Enum.at(record, 2),
              date: date
            }
          ]
        }
      ]
    }
  end

  defp maybe_nil_record(nil), do: %{id: nil}
  defp maybe_nil_record(record), do: record
end
