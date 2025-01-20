defmodule Mejora.Properties.Property do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias Mejora.Properties.PropertyMembership
  alias Mejora.Transactions.Transaction
  alias __MODULE__, as: Property

  schema "properties" do
    field :street, :string
    field :number, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :comments, :string
    field :index, :integer, virtual: true
    field :neighborhood_id, :integer

    has_many :property_memberships, PropertyMembership
    has_many :users, through: [:property_memberships, :user]
    has_many :transactions, Transaction, foreign_key: :association_id, references: :id

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:street, :number])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Property{}
    |> cast(attrs, fields)
  end

  defp parse_record(record) do
    %{
      street: Enum.at(record, 0),
      number: parse_number(Enum.at(record, 1)),
      comments: Enum.at(record, 3),
      status: parse_status(Enum.at(record, 2)),
      neighborhood_id: Enum.at(record, 4)
    }
  end
end
