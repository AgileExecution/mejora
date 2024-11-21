defmodule Mejora.Importers.Boards do
  def process(tab) do
    Xlsxir.get_list(tab)
  end
end
