defmodule Mejora.Importers.Transactions do
  def process(tab) do
    Xlsxir.get_list(tab)
  end
end
