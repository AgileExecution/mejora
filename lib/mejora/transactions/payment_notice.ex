defmodule Mejora.Transactions.PaymentNotice do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias Mejora.Properties.Property
  alias Mejora.Transactions.Transaction

  alias __MODULE__, as: PaymentNotice

  schema "payment_notices" do
    field :due_date, :date
    field :invoice_number, :string
    field :total, :decimal
    field :status, Ecto.Enum, values: [:unpaid, :pending, :paid, :cancelled]
    field :comments, :string
    field :metadata, :map
    field :index, :integer, virtual: true

    belongs_to :property, Property

    has_many :transactions, Transaction,
      where: [association_type: "PaymentNotice"],
      foreign_key: :association_id

    timestamps()
  end

  def create_changeset(_changeset, _attrs, _), do: nil
  def update_changeset(_changeset, _attrs, _), do: nil

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %PaymentNotice{}
    |> cast(attrs, fields)
    |> cast_assoc(:transactions, with: &Transaction.changeset/2)
  end

  def parse_record(record) do
    property =
      [street: Enum.at(record, 0), number: Enum.at(record, 1)]
      |> Mejora.Properties.get_properties()
      |> List.first()
      |> maybe_nil_record()

    date = parse_datetime(Enum.at(record, 2))

    %{
      status: :paid,
      due_date: date,
      comments: Enum.at(record, 3),
      total: Enum.at(record, 4),
      property_id: property.id,
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

  defp maybe_nil_record(nil), do: %{id: nil}
  defp maybe_nil_record(record), do: record

  def fields_for_admin_backend() do
    [
      due_date: %{
        module: Backpex.Fields.Date,
        label: "Due Date"
      },
      invoice_number: %{
        module: Backpex.Fields.Text,
        label: "Invoice Number"
      },
      total: %{
        module: Backpex.Fields.Currency,
        label: "Total"
      },
      status: %{
        module: Backpex.Fields.Select,
        label: "Status",
        options: [Unpaid: :unpaid, Pending: :pending, Paid: :paid, Cancelled: :cancalled]
      },
      comments: %{
        module: Backpex.Fields.Textarea,
        label: "Comments"
      },
      property: %{
        module: Backpex.Fields.Select,
        label: "Property",
        options: []
      }
    ]
  end
end
