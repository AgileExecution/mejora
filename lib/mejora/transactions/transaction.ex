defmodule Mejora.Transactions.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mejora.Transactions.TransactionRow

  schema "transactions" do
    field :total_amount, :decimal
    field :author, :string
    field :transaction_type, Ecto.Enum, values: [:income, :outcome]
    field :payment_date, :utc_datetime
    field :comments, :string
    field :association_id, :integer
    field :association_type, :string
    field :date_range, :map, virtual: true

    has_many :transaction_rows, TransactionRow

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :total_amount,
      :author,
      :transaction_type,
      :payment_date,
      :comments,
      :association_id,
      :association_type,
      :date_range
    ])
    |> validate_required([
      :total_amount,
      :transaction_type,
      :payment_date,
      :association_id,
      :association_type
    ])
    |> cast_assoc(:transaction_rows)
  end
end
