let
    // Conectar a la carpeta donde están los templates de captura
    Source = Folder.Files(FolderPath),
    FilterXlsx = Table.SelectRows(Source, each Text.EndsWith([Name], ".xlsx")),

    // Extraer la hoja "Cargas" de cada archivo
    AddContent = Table.AddColumn(FilterXlsx, "Tables", each
        let
            wb = Excel.Workbook([Content], null, true),
            sheet = wb{[Item="Cargas", Kind="Sheet"]}[Data],
            promoted = Table.PromoteHeaders(sheet, [PromoteAllScalars=true])
        in
            promoted
    ),

    KeepRelevant = Table.SelectColumns(AddContent, {"Name", "Tables"}),
    Expanded = Table.ExpandTableColumn(KeepRelevant, "Tables", {
        "LoadID", "Status", "ActivityDate", "Year", "Week",
        "PickupLocation", "PickupCity",
        "PlannedPallets", "ActualPallets", "MaxPallets",
        "UnitType", "CarrierName", "TotalChargeUSD",
        "PlantaKey", "ModoKey", "ClienteKey",
        "IsOnTime", "IsInFull"
    }),

    // Generar DateKey desde ActivityDate
    AddDateKey = Table.AddColumn(Expanded, "DateKey", each
        Date.Year([ActivityDate]) * 10000
        + Date.Month([ActivityDate]) * 100
        + Date.Day([ActivityDate]),
        Int64.Type
    ),

    // Calcular Saturación
    AddSaturation = Table.AddColumn(AddDateKey, "Saturation", each
        if [MaxPallets] = 0 or [MaxPallets] = null then null
        else [ActualPallets] / [MaxPallets],
        type number
    ),

    SetTypes = Table.TransformColumnTypes(AddSaturation, {
        {"LoadID", type text},
        {"Status", type text},
        {"ActivityDate", type date},
        {"Year", Int64.Type},
        {"Week", Int64.Type},
        {"PlannedPallets", type number},
        {"ActualPallets", type number},
        {"MaxPallets", type number},
        {"UnitType", type text},
        {"CarrierName", type text},
        {"TotalChargeUSD", Currency.Type},
        {"PlantaKey", type text},
        {"ModoKey", type text},
        {"ClienteKey", type text},
        {"IsOnTime", Int64.Type},
        {"IsInFull", Int64.Type},
        {"Saturation", Percentage.Type}
    }),

    RemoveSource = Table.RemoveColumns(SetTypes, {"Name"})
in
    RemoveSource

// --------------------------------------------------------------------------
// ALTERNATIVA: Leer directamente del raw data (Juarez pilot format)
// --------------------------------------------------------------------------
// let
//     Source = Excel.Workbook(File.Contents("Juarez pilot week 9.xlsx"), null, true),
//     Sheet = Source{[Item="Sheet1", Kind="Sheet"]}[Data],
//     Promoted = Table.PromoteHeaders(Sheet, [PromoteAllScalars=true]),
//     Renamed = Table.RenameColumns(Promoted, {
//         {"Load ", "LoadID"},
//         {"Week ", "Week"},
//         {"Activity Date ", "ActivityDate"},
//         {"Pickup Location", "PickupLocation"},
//         {"Pickup City", "PickupCity"},
//         {"Planned Pallets ", "PlannedPallets"},
//         {"Actual Pallets", "ActualPallets"},
//         {"Max pallet per eq type", "MaxPallets"},
//         {"Unit ", "UnitType"},
//         {"Carrier Display Name", "CarrierName"},
//         {"Total Charge (USD)", "TotalChargeUSD"}
//     }),
//     AddPlantaKey = Table.AddColumn(Renamed, "PlantaKey", each "JUP1", type text),
//     AddModoKey = Table.AddColumn(AddPlantaKey, "ModoKey", each "CB", type text),
//     AddClienteKey = Table.AddColumn(AddModoKey, "ClienteKey", each "OTHER", type text),
//     AddIsOnTime = Table.AddColumn(AddClienteKey, "IsOnTime", each
//         if [Status] = null or [Status] = "" then 1 else 0, Int64.Type),
//     AddIsInFull = Table.AddColumn(AddIsOnTime, "IsInFull", each
//         if [ActualPallets] >= [PlannedPallets] then 1 else 0, Int64.Type)
// in
//     AddIsInFull
