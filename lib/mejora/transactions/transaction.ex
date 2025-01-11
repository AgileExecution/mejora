defmodule Mejora.Transactions.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

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
    fields = __schema__(:fields)

    transaction
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:transaction_rows)
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields)

    attrs =
      record
      |> parse_attrs()
      |> Map.put(:index, index)

    %Transaction{}
    |> cast(attrs, fields)
  end

  defp parse_attrs(record) do
    Enum.reduce(record, %{}, fn
      {nil, _value}, acc -> acc
      {key, value}, acc -> Map.put(acc, to_atom(key), value)
    end)
  end

  def to_atom(key), do: String.to_atom(key)
end
