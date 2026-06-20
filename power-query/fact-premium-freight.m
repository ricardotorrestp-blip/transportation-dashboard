let
    Source = Excel.Workbook(File.Contents(NAMDashboardPath), null, true),

    ProcessSheet = (sheetName as text, plantaKey as text) =>
        let
            Sheet = Source{[Item=sheetName, Kind="Sheet"]}[Data],
            AllRows = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),
            FirstCol = Table.ColumnNames(AllRows){0},

            AllLabels = Table.Column(AllRows, FirstCol),
            PFIdx = List.PositionOf(AllLabels, "PF Customer CB")
                ?? List.PositionOf(AllLabels, "PF Customer CB (K USD)"),

            // Tomar las filas de clientes después del header PF
            PFRows = Table.Range(AllRows, PFIdx + 1, 3),
            FilterValid = Table.SelectRows(PFRows, each
                Record.Field(_, FirstCol) <> null
                and not Text.StartsWith(Text.From(Record.Field(_, FirstCol)), "`")
            ),

            Unpivoted = Table.UnpivotOtherColumns(FilterValid, {FirstCol}, "WeekLabel", "PF_KUSD"),
            CleanRows = Table.SelectRows(Unpivoted, each [PF_KUSD] <> null and not Text.StartsWith([WeekLabel], "Unnamed")),

            AddPlanta = Table.AddColumn(CleanRows, "PlantaKey", each plantaKey, type text),
            Renamed = Table.RenameColumns(AddPlanta, {{FirstCol, "ClienteName"}})
        in
            Renamed,

    Toluca = ProcessSheet("Toluca", "TOL"),
    JUP1 = ProcessSheet("JUP1", "JUP1"),
    JUP2 = ProcessSheet("JUP2", "JUP2"),

    Combined = Table.Combine({Toluca, JUP1, JUP2}),

    SetTypes = Table.TransformColumnTypes(Combined, {
        {"PF_KUSD", type number},
        {"PlantaKey", type text},
        {"ClienteName", type text},
        {"WeekLabel", type text}
    })
in
    SetTypes
