defmodule Mejora.Providers do
  import Ecto.Query, warn: false

  alias Mejora.Providers.Provider
  alias Mejora.Repo

  def create_provider(attrs) do
    %Provider{}
    |> Provider.changeset(attrs)
    |> Repo.insert()
  end
end
