defmodule MejoraWeb.RateLimiter do
  def check_rate_limit(action, key, limit, period_ms),
    do:
      "#{action}:#{key}"
      |> Hammer.check_rate(period_ms, limit)
      |> then(fn
        {:allow, _count} -> :ok
        {:deny, _count} -> {:error, :rate_limited}
      end)
end
