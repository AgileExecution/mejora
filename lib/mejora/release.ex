defmodule Mejora.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :mejora
  @start_apps [:logger, :ssl, :postgrex, :ecto]

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    stop()
  end

  def rollback(repo, version) do
    load_app()

    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

    stop()
  end

  def seed(opts \\ []) do
    load_app()

    for repo <- repos() do
      if Keyword.get(opts, :truncate, false),
        do: do_truncate()

      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &seed_repo/1)
    end

    stop()
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    IO.puts "Loading mejora..."
    :ok = Application.load(@app)

    IO.puts "Starting dependencies..."
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts "Starting repos..."
    @app
    |> Application.get_env(:ecto_repos, [])
    |> Enum.each(&(&1.start_link(pool_size: 1)))
  end

  defp do_truncate do
    [
      "neighborhoods",
      "properties",
      "users",
      "boards",
      "providers",
      "transactions",
      "transaction_rows",
      "payment_notices",
      "purchase_notices",
      "quotas",
      "board_memberships",
      "property_memberships",
      "user_tokens"
    ]
    |> Enum.each(fn table ->
      case Mejora.Repo.query("TRUNCATE TABLE #{table} CASCADE") do
        {:ok, _result} ->
          IO.puts("#{table} table truncated successfully.")

        {:error, reason} ->
          IO.puts("Failed to truncate #{table} table: #{inspect(reason)}")
      end
    end)
  end

  defp seed_repo(repo) do
    seed_path = priv_dir(repo, "seeds.exs")

    if File.exists?(seed_path) do
      IO.puts("Running seeds for #{inspect(repo)}")
      Code.eval_file(seed_path)
    end
  end

  defp priv_dir(repo, filename) do
    repo_otp_app = repo.config()[:otp_app]
    app_path = Application.app_dir(repo_otp_app)
    Path.join([app_path, "priv/repo", filename])
  end

  defp stop do
    IO.puts "Success!"
    :init.stop()
  end
end
