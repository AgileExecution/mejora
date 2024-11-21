defmodule Mejora.Transactions.TransactionRow do
  use Ecto.Schema

  import Ecto.Changeset

  alias Mejora.Transactions.Transaction

  schema "transaction_rows" do
    field :amount, :decimal
    field :date, :date

    belongs_to :transaction, Transaction

    timestamps()
  end

  def changeset(transaction_row, attrs) do
    transaction_row
    |> cast(attrs, [:amount, :date, :transaction_id])
    |> validate_required([:amount, :date])
  end
end
