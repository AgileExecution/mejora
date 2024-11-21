defmodule Mejora.Importers.People do
  def process(tab) do
    Xlsxir.get_list(tab)
  end
end
