defmodule Mejora.Properties.Status do
  import Ecto.Query, warn: false
  alias Mejora.Repo
  alias Mejora.Neighborhoods.Quota
  alias Mejora.Properties.Property
  alias Mejora.Transactions.PaymentNotice

  def get_property_status(property_id) do
    expected_amount = get_expected_amount(property_id)
    transactions_total = get_transactions_total(property_id)

    cond do
      Decimal.compare(transactions_total, expected_amount) == :eq -> {:ok, :current}
      Decimal.compare(transactions_total, expected_amount) == :lt -> {:ok, :late}
      Decimal.compare(transactions_total, expected_amount) == :gt -> {:ok, :advance}
      true -> {:error, "Unable to determine status"}
    end
  end

  defp get_neighborhood_id(property_id) do
    property = Repo.get(Property, property_id)

    case property do
      nil -> {:error, "Property not found"}
      _ -> {:ok, property.neighborhood_id}
    end
  end

  def get_expected_amount(property_id) do
    with {:ok, neighborhood_id} <- get_neighborhood_id(property_id) do
      Quota
      |> where(
        [q],
        q.neighborhood_id == ^neighborhood_id and
          q.status == :active
      )
      |> Repo.all()
      |> Enum.reduce(Decimal.new(0), fn quota, acc ->
        current_date = Date.utc_today()
        cutoff_day = 15

        effective_end_date = min_date(quota.end_date || current_date, current_date)

        months_passed =
          calculate_months_passed(quota.start_date, effective_end_date, cutoff_day)

        monthly_amount = Decimal.new(quota.amount)
        total_amount = Decimal.mult(months_passed, monthly_amount)

        Decimal.add(total_amount, acc)
      end)
    else
      {:error, reason} ->
        IO.inspect(reason, label: "Error fetching neighborhood_id")
        Decimal.new(0)
    end
  end

  def get_transactions_total(property_id) do
    query =
      from pn in PaymentNotice,
        where: pn.property_id == ^property_id and pn.status == :paid,
        select: sum(pn.total)

    Repo.one(query) || Decimal.new(0)
  end

  defp calculate_months_passed(start_date, end_date, cutoff_day) do
    start_year = start_date.year
    start_month = start_date.month
    end_year = end_date.year
    end_month = end_date.month

    months_passed = (end_year - start_year) * 12 + (end_month - start_month)

    if end_date.day < cutoff_day do
      max(months_passed - 1, 0)
    else
      months_passed
    end
  end

  defp min_date(date1, date2), do: if(Date.compare(date1, date2) == :gt, do: date2, else: date1)
end
