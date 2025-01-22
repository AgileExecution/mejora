defmodule Mejora.Neighborhoods.Neighborhood do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias __MODULE__, as: Neighborhood
  alias Mejora.Transactions.Invoice

  @required_fields [
    :name,
    :type,
    :state,
    :city,
    :zipcode,
    :email
  ]

  schema "neighborhoods" do
    field :name, :string
    field :type, :string
    field :state, :string
    field :city, :string
    field :zipcode, :string
    field :email, :string
    field :representative, :string
    field :init_date, :date
    field :bank_account, :string
    field :electoral_district, :string
    field :total_count_properties, :integer
    field :total_count_active_properties, :integer
    field :comments, :string
    field :index, :integer, virtual: true

    has_many :invoices, Invoice

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required(@required_fields)
  end

  def edit_changeset(changeset, attrs) do
    changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Neighborhood{}
    |> cast(attrs, fields)
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 0),
      commercial_name: Enum.at(record, 0),
      type: Enum.at(record, 1),
      state: Enum.at(record, 3),
      city: Enum.at(record, 4),
      zipcode: parse_number(Enum.at(record, 5)),
      email: Enum.at(record, 6),
      electoral_district: parse_number(Enum.at(record, 7)),
      representative: Enum.at(record, 8),
      init_date: parse_date(Enum.at(record, 9)),
      bank_account: Enum.at(record, 10)
    }
  end
end
