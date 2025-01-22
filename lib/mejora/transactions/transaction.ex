defmodule Mejora.Transactions.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mejora.Transactions.{Invoice, TransactionRow}

  @required_fields [
    :total_amount,
    :payment_date
  ]

  schema "transactions" do
    field :total_amount, :decimal
    field :author, :string
    field :payment_date, :utc_datetime
    field :comments, :string
    field :date_range, :map, virtual: true
    field :index, :integer, virtual: true

    belongs_to :invoice, Invoice
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
end
