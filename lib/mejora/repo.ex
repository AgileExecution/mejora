defmodule Mejora.Repo do
  use Ecto.Repo,
    otp_app: :mejora,
    adapter: Ecto.Adapters.Postgres
end
