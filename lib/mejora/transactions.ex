defmodule Mejora.Transactions do
  import Ecto.Query, warn: false

  alias Mejora.Repo
  alias Mejora.Transactions.{Invoice, Transaction, TransactionRow}

  %{
    date_range: %{lower: "", upper: ""}
  }

  def create_transaction(attrs) do
    transaction_row_attrs = get_transaction_row_attrs(attrs)

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:transaction_rows, transaction_row_attrs)
    |> Repo.insert()
  end

  defp get_transaction_row_attrs(attrs) do
    date_range = Map.get(attrs, :date_range)
    total_amount = Map.get(attrs, :total_amount)

    date_list = generate_monthly_dates(date_range[:lower], date_range[:upper])

    Enum.map(date_list, fn date ->
      TransactionRow.changeset(%TransactionRow{}, %{
        amount: Decimal.div(total_amount, Enum.count(date_list)),
        date: date
      })
    end)
  end

  def generate_monthly_dates(start_date, end_date) do
    Stream.unfold(start_date, fn current_date ->
      if Timex.compare(current_date, end_date) <= 0 do
        next_date = Timex.shift(current_date, months: 1)
        {current_date, next_date}
      else
        nil
      end
    end)
  end

  def unpaid_invoices(property_id) do
    filters = [status: :unpaid, property_id: property_id]

    Invoice
    |> from()
    |> where(^dynamic_filters(filters))
    |> Repo.all()
  end

  defp dynamic_filters(filters) when is_list(filters),
    do: Enum.reduce(filters, dynamic(true), &filter_by/2)

  defp filter_by({:status, status}, dynamic),
    do: dynamic([i], ^dynamic and i.status == ^status)

  defp filter_by({:property_id, property_id}, dynamic),
    do: dynamic([i], ^dynamic and i.property_id == ^property_id)

  defp filter_by({_, _}, dynamic), do: dynamic
end
