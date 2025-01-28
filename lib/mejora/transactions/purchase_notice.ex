defmodule Mejora.Transactions.PurchaseNotice do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias Mejora.Neighborhoods.Neighborhood
  alias Mejora.Transactions.Transaction

  alias __MODULE__, as: PurchaseNotice

  schema "purchase_notices" do
    field :due_date, :date
    field :invoice_number, :string
    field :total, :decimal
    field :status, Ecto.Enum, values: [:unpaid, :pending, :paid, :cancelled]
    field :comments, :string
    field :metadata, :map
    field :index, :integer, virtual: true

    belongs_to :neighborhood, Neighborhood

    has_many :transactions, Transaction,
      where: [association_type: "PurchaseNotice"],
      foreign_key: :association_id

    timestamps()
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %PurchaseNotice{}
    |> cast(attrs, fields)
    |> cast_assoc(:transactions, with: &Transaction.changeset/2)
  end

  def parse_record(record) do
    neighborhood =
      Neighborhood
      |> Mejora.Repo.get_by(name: Enum.at(record, 4))
      |> maybe_nil_record()

    date = parse_datetime(Enum.at(record, 0))

    %{
      status: :paid,
      due_date: date,
      comments: Enum.at(record, 3),
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
