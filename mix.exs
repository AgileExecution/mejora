defmodule Mejora.MixProject do
  use Mix.Project

  def project do
    [
      app: :mejora,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ],
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        plt_core_path: ".dialyzer_cache/",
        plt_local_path: ".dialyzer_cache/",
        plt_file: {:no_warn, ".dialyzer_cache/mejora.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Mejora.Application, []},
      extra_applications: [:logger, :runtime_tools, :xlsxir]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 3.0"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:hackney, "~> 1.9"},
      {:ecto_enum, "~> 1.4.0"},
      {:ecto_lock, "~> 0.1.2"},
      {:ecto_psql_extras, "~> 0.6"},
      {:ecto_savepoint, "~> 0.1.0"},
      {:elixlsx, "~> 0.4.1"},
      {:eqrcode, "~> 0.1.7"},
      {:ex_aws_s3, "~> 2.1"},
      {:ex_aws, "~> 2.1.9"},
      {:ex_env, "~> 0.3.1"},
      {:ex_machina, "~> 2.7"},
      {:gen_enum, "~> 0.4.1"},
      {:guardian, "~> 2.1"},
      {:libcluster_ec2, "0.6.0"},
      {:libcluster, "~> 3.3"},
      {:number, "~> 1.0.0"},
      {:oban, "~> 2.18.1"},
      {:timex, "~> 3.1"},
      {:xlsxir, "~> 1.6.4"},
      {:con_cache, "~> 0.13"},
      {:ecto_fragment_extras, "~> 0.3.0"},
      {:ecto_ltree, "~> 0.4.0"},
      {:gen_smtp, "~> 1.1"},
      {:heroicons_liveview, "~> 0.3.0"},

      # Development
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22.0", only: :dev},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:salad_ui, "~> 0.14"},
      {:tails, "~> 0.1"},

      # Test
      {:excoveralls, "~> 0.18", only: :test},
      {:mock, "~> 0.3.7", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind mejora", "esbuild mejora"],
      "assets.deploy": [
        "tailwind mejora --minify",
        "esbuild mejora --minify",
        "phx.digest"
      ]
    ]
  end
end
