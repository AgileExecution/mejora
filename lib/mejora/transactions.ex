defmodule Mejora.Transactions do
  import Ecto.Query, warn: false

  alias Mejora.Repo
  alias Mejora.Transactions.Transaction
  alias Mejora.Transactions.TransactionRow

  %{
    date_range: %{lower: "", upper: ""}
  }

  def create_transaction(attrs) do
    transaction_row_attrs = get_transaction_row_attrs(attrs)

    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:transaction_rows, transaction_row_attrs)
    |> IO.inspect()
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
end
