defmodule Mejora.Providers.Provider do
  use Ecto.Schema

  import Ecto.Changeset
  import Mejora.Utils

  alias __MODULE__, as: Provider

  schema "providers" do
    field :name, :string
    field :rfc, :string
    field :status, Ecto.Enum, values: [:active, :inactive], default: :active
    field :description, :string
    field :bank_account, :string
    field :address, :string
    field :service, :string
    field :legal_name, :string
    field :index, :integer, virtual: true

    timestamps()
  end

  def changeset(changeset, attrs) do
    fields = __schema__(:fields)

    changeset
    |> cast(attrs, fields)
    |> validate_required([:name])
  end

  def embedded_changeset({record, index}) do
    fields = __schema__(:fields) ++ [:index]

    attrs =
      record
      |> parse_record()
      |> Map.put(:index, index)

    %Provider{}
    |> cast(attrs, fields)
    |> validate_required([:name, :rfc, :legal_name])
  end

  defp parse_record(record) do
    %{
      name: Enum.at(record, 0),
      legal_name: Enum.at(record, 1),
      rfc: parse_string(Enum.at(record, 2)),
      address: Enum.at(record, 3),
      bank_account: parse_number(Enum.at(record, 4)),
      service: Enum.at(record, 5)
    }
  end
end
