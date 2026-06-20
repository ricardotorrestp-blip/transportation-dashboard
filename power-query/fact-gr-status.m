let
    Source = Excel.Workbook(File.Contents(NAMDashboardPath), null, true),

    ProcessSheet = (sheetName as text, plantaKey as text) =>
        let
            Sheet = Source{[Item=sheetName, Kind="Sheet"]}[Data],
            AllRows = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),
            FirstCol = Table.ColumnNames(AllRows){0},

            // Localizar la sección "GR Status"
            GRLabels = {"Sensitivity std", "GR", "Missing GR"},
            GRRows = Table.SelectRows(AllRows, each List.Contains(GRLabels, Record.Field(_, FirstCol))),

            // Las columnas CW son dinámicas — tomar las que tienen datos
            Unpivoted = Table.UnpivotOtherColumns(GRRows, {FirstCol}, "WeekLabel", "Value"),
            CleanRows = Table.SelectRows(Unpivoted, each [Value] <> null and not Text.StartsWith([WeekLabel], "Unnamed")),

            AddPlanta = Table.AddColumn(CleanRows, "PlantaKey", each plantaKey, type text),
            Renamed = Table.RenameColumns(AddPlanta, {{FirstCol, "Metric"}}),

            // Pivot métricas como columnas
            Pivoted = Table.Pivot(Renamed, List.Distinct(Renamed[Metric]), "Metric", "Value"),

            // Agregar campos calculados para el waterfall
            AddCommitment = Table.AddColumn(Pivoted, "Commitment_KUSD", each
                [#"Sensitivity std"] - [GR],
                type number
            ),

            Final = Table.RenameColumns(AddCommitment, {
                {"Sensitivity std", "Sensitivity_Std_KUSD"},
                {"GR", "GR_KUSD"},
                {"Missing GR", "MissingGR_KUSD"}
            })
        in
            Final,

    Toluca = ProcessSheet("Toluca", "TOL"),
    JUP1 = ProcessSheet("JUP1", "JUP1"),
    JUP2 = ProcessSheet("JUP2", "JUP2"),

    Combined = Table.Combine({Toluca, JUP1, JUP2}),

    SetTypes = Table.TransformColumnTypes(Combined, {
        {"Sensitivity_Std_KUSD", type number},
        {"GR_KUSD", type number},
        {"MissingGR_KUSD", type number},
        {"Commitment_KUSD", type number}
    })
in
    Combined
