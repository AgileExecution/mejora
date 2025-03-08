# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mejora.Repo.insert!(%Mejora.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Mejora.Repo
alias Ecto.Adapters.SQL

file_path = Path.join(:code.priv_dir(:mejora), "repo/dump.sql")
sql = File.read!(file_path)

sql
|> String.split(";", trim: true)
|> Enum.each(fn statement ->
  cleaned_statement = String.trim(statement)

  if cleaned_statement != "" do
    SQL.query!(Repo, cleaned_statement, [])
  end
end)
