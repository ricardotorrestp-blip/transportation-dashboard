let
    Source = Excel.Workbook(File.Contents(NAMDashboardPath), null, true),

    ProcessSheet = (sheetName as text, plantaKey as text) =>
        let
            Sheet = Source{[Item=sheetName, Kind="Sheet"]}[Data],
            AllRows = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),
            FirstCol = Table.ColumnNames(AllRows){0},

            // Localizar carriers de demurrages (después de la fila "Demurrages")
            AllLabels = Table.Column(AllRows, FirstCol),
            DemIdx = List.PositionOf(AllLabels, "Demurrages")
                ?? List.PositionOf(AllLabels, "Demurrages (Hrs)"),

            // Tomar filas después del header de demurrages, excluyendo totales
            DemRows = Table.Range(AllRows, DemIdx + 1, 3),
            FilterValid = Table.SelectRows(DemRows, each
                Record.Field(_, FirstCol) <> null
                and Record.Field(_, FirstCol) <> "Total Accum"
                and not Text.StartsWith(Text.From(Record.Field(_, FirstCol)), "`")
            ),

            Unpivoted = Table.UnpivotOtherColumns(FilterValid, {FirstCol}, "WeekLabel", "Horas"),
            CleanRows = Table.SelectRows(Unpivoted, each [Horas] <> null and not Text.StartsWith([WeekLabel], "Unnamed")),

            AddPlanta = Table.AddColumn(CleanRows, "PlantaKey", each plantaKey, type text),
            Renamed = Table.RenameColumns(AddPlanta, {{FirstCol, "CarrierName"}})
        in
            Renamed,

    Toluca = ProcessSheet("Toluca", "TOL"),
    JUP1 = ProcessSheet("JUP1", "JUP1"),
    JUP2 = ProcessSheet("JUP2", "JUP2"),

    Combined = Table.Combine({Toluca, JUP1, JUP2}),

    SetTypes = Table.TransformColumnTypes(Combined, {
        {"Horas", type number},
        {"PlantaKey", type text},
        {"CarrierName", type text},
        {"WeekLabel", type text}
    })
in
    SetTypes
