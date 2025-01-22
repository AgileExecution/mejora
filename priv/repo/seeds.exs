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
alias Mejora.Boards.Board
alias Mejora.Neighborhoods.{Neighborhood, Quota}
alias Mejora.Properties.Property
alias Mejora.Accounts.User
alias Mejora.Providers.Provider
alias Mejora.Transactions.Invoice

[
  {
    [
      "Genesis",
      "2019-02-07",
      "2024-08-11",
      "Primera Mesa Directiva",
      "Jaime",
      "Pinal",
      "Maldonado",
      "Ana Laura",
      "Calderón",
      "Cardoza",
      "Felipe Arturo",
      "Jiménez",
      "López",
      "Inactiva",
      nil
    ],
    0
  },
  {
    [
      "Movimiento Naranja",
      "2024-08-12",
      "Presente",
      "Segunda Mesa Directiva",
      "Lucia Berenice",
      "López",
      "Saenz",
      "Ana Laura",
      "Calderón",
      "Cardoza",
      "Jorge Saúl",
      "Canales",
      "Treviño",
      "Treviño",
      nil
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> Board.embedded_changeset()
  |> Repo.insert!()
end)

[neighborhood] =
  [
    {
      [
        "Residencial 15 de Mayo II",
        "Fraccionamiento",
        "México",
        "Nuevo León",
        "Guadalupe",
        "67170",
        "15demayoii@gmail.com",
        nil,
        "Itzel Soledad Castillo Almanza",
        "2024-11-22",
        nil
      ],
      0
    }
  ]
  |> Enum.map(fn record ->
    record
    |> Neighborhood.embedded_changeset()
    |> Repo.insert!()
  end)

[
  {
    [
      "200",
      "2020-01-01",
      "2024-07-01",
      "Inactivo",
      "Cuota inicial",
      neighborhood.id
    ],
    0
  },
  {
    [
      "350",
      "2024-08-01",
      "Presente",
      "Activo",
      nil,
      neighborhood.id
    ],
    1
  }
]
|> Enum.map(fn record ->
  record
  |> Quota.embedded_changeset()
  |> Repo.insert!()
end)

[property_one, property_two] =
  [
    {
      [
        "15 de Mayo",
        "790",
        "Activa",
        nil,
        neighborhood.id
      ],
      0
    },
    {
      [
        "Colima",
        "300",
        "Activa",
        nil,
        neighborhood.id
      ],
      1
    }
  ]
  |> Enum.map(fn record ->
    record
    |> Property.embedded_changeset()
    |> Repo.insert!()
  end)

[
  {
    [
      "15 de Mayo 790",
      "15 de Mayo",
      "790",
      "Silvia Alcalá Suárez",
      "8110313058",
      "silvia.alcala@borelit.com.mx",
      "Víctor",
      "Vargas",
      "García",
      nil,
      nil,
      "SI",
      "SI",
      "NO"
    ],
    0
  },
  {
    [
      "Colima 300",
      "Colima",
      "300",
      "Luis Ignacio Cejudo Fontes",
      "8115898281",
      "email@luisignac.io",
      "Luis Ignacio",
      "Cejudo",
      "Fontes",
      nil,
      nil,
      "SI",
      "SI",
      "NO"
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> User.embedded_changeset()
  |> Repo.insert!()
end)

[
  {
    [
      "CFE",
      "Comisión Federal de Electricidad",
      "CSS160330CP7",
      "Río Ródano No. 14, colonia Cuauhtémoc, Alcaldía Cuauhtémoc, Código Postal 06500, Ciudad de México",
      nil,
      "Electricidad"
    ],
    0
  },
  {
    [
      "Agua y Drenaje",
      "Servicios de Agua y Drenaje de Monterrey IPD",
      "TIN6008112W0",
      "Mariano Matamoros 1717, Centro, 64060 Monterrey, N.L.",
      nil,
      "Agua y Drenaje"
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> Provider.embedded_changeset()
  |> Repo.insert!()
end)

[
  {
    [
      "Colima",
      "300",
      {2024, 7, 11},
      "Mensualidad faltante",
      "200.00",
      :sale
    ],
    0
  },
  {
    [
      "15 de Mayo",
      "790",
      {2024, 8, 11},
      "Mensualidad de dos meses",
      "700.00",
      :sale
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> Invoice.embedded_changeset()
  |> Repo.insert!()
end)

[
  {
    [
      {2024, 7, 11},
      "Agua y Drenaje",
      "300",
      nil,
      "Residencial 15 de Mayo II",
      :purchase
    ],
    0
  },
  {
    [
      {2024, 6, 11},
      "CFE",
      "100",
      nil,
      "Residencial 15 de Mayo II",
      :purchase
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> Invoice.embedded_changeset()
  |> Repo.insert!()
end)

[
  {
    [
      "Colima",
      "300",
      {2024, 8, 11},
      "Mensualidad faltante",
      "200.00",
      :sale
    ],
    0
  },
  {
    [
      "15 de Mayo",
      "790",
      {2024, 9, 11},
      "Mensualidad de dos meses",
      "700.00",
      :sale
    ],
    1
  }
]
|> Enum.each(fn record ->
  record
  |> Invoice.embedded_changeset()
  |> Repo.insert!()
  |> then(fn record ->
    record = Ecto.Changeset.change(record, status: :unpaid)
    Repo.update(record)
  end)
end)
