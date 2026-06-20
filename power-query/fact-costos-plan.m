let
    // Leer el NAM Dashboard como fuente del BP2026 y Sensitivity
    Source = Excel.Workbook(File.Contents(NAMDashboardPath), null, true),

    // Función para procesar cada hoja (planta)
    ProcessSheet = (sheetName as text, plantaKey as text) =>
        let
            Sheet = Source{[Item=sheetName, Kind="Sheet"]}[Data],
            Promoted = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),

            // Primera columna contiene los labels de fila
            FirstColName = Table.ColumnNames(Promoted){0},
            MonthCols = List.RemoveFirstN(Table.ColumnNames(Promoted), 1),

            // Filtrar solo filas de BP y modos
            ValidRows = {"BP2026", "Actual/Sens", "MX-MX", "US-US", "Ocean", "Cross Border", "4PL"},
            Filtered = Table.SelectRows(Promoted, each List.Contains(ValidRows, Record.Field(_, FirstColName))),

            // Unpivot meses
            Unpivoted = Table.UnpivotOtherColumns(Filtered, {FirstColName}, "MonthLabel", "KUSD"),

            // Filtrar columnas vacías (Unnamed)
            CleanUnpivot = Table.SelectRows(Unpivoted, each not Text.StartsWith([MonthLabel], "Unnamed")),

            // Pivot para tener BP2026 y Actual/Sens como columnas, y modos como filas
            AddPlanta = Table.AddColumn(CleanUnpivot, "PlantaKey", each plantaKey, type text),

            // Mapear nombre de fila a ModoKey
            AddModoKey = Table.AddColumn(AddPlanta, "ModoKey", each
                if Record.Field(_, FirstColName) = "MX-MX" then "MXMX"
                else if Record.Field(_, FirstColName) = "US-US" then "USUS"
                else if Record.Field(_, FirstColName) = "Ocean" then "OCN"
                else if Record.Field(_, FirstColName) = "Cross Border" then "CB"
                else if Record.Field(_, FirstColName) = "4PL" then "4PL"
                else null,
                type text
            ),

            AddRowType = Table.RenameColumns(
                Table.SelectRows(AddModoKey, each [ModoKey] <> null),
                {{FirstColName, "RowLabel"}}
            ),

            // Extraer mes/año del MonthLabel (formato "Jan 2026")
            AddDate = Table.AddColumn(AddRowType, "Date", each
                Date.From(DateTime.From([MonthLabel] & " 1")),
                type date
            ),
            AddDateKey = Table.AddColumn(AddDate, "DateKey", each
                Date.Year([Date]) * 10000 + Date.Month([Date]) * 100 + 1,
                Int64.Type
            ),

            Final = Table.SelectColumns(AddDateKey, {
                "PlantaKey", "DateKey", "ModoKey", "RowLabel", "KUSD"
            })
        in
            Final,

    // Procesar las 3 plantas
    Toluca = ProcessSheet("Toluca", "TOL"),
    JUP1 = ProcessSheet("JUP1", "JUP1"),
    JUP2 = ProcessSheet("JUP2", "JUP2"),

    Combined = Table.Combine({Toluca, JUP1, JUP2}),

    SetTypes = Table.TransformColumnTypes(Combined, {
        {"KUSD", type number}
    })
in
    SetTypes
