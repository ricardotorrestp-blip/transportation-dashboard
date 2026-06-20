let
    Source = Excel.Workbook(File.Contents(FolderPath & "\captura-semanal.xlsx"), null, true),
    CarrierSheet = Source{[Item="Carriers", Kind="Sheet"]}[Data],
    Promoted = Table.PromoteHeaders(CarrierSheet, [PromoteAllScalars=true]),
    SetTypes = Table.TransformColumnTypes(Promoted, {
        {"CarrierKey", type text},
        {"CarrierName", type text},
        {"CarrierType", type text}
    })
in
    SetTypes

// --------------------------------------------------------------------------
// ALTERNATIVA: Si no hay hoja de Carriers, extraer de FACT_Cargas (raw data)
// --------------------------------------------------------------------------
// let
//     Source = FACT_Cargas,
//     Distinct = Table.Distinct(Table.SelectColumns(Source, {"CarrierName"})),
//     AddKey = Table.AddIndexColumn(Distinct, "CarrierKey", 1, 1, Int64.Type),
//     AddKeyText = Table.TransformColumnTypes(
//         Table.AddColumn(AddKey, "CarrierKeyText",
//             each "CAR" & Text.PadStart(Text.From([CarrierKey]), 3, "0"), type text),
//         {}),
//     AddType = Table.AddColumn(AddKeyText, "CarrierType", each "Road", type text),
//     Final = Table.RenameColumns(
//         Table.RemoveColumns(AddKeyText, {"CarrierKey"}),
//         {{"CarrierKeyText", "CarrierKey"}})
// in
//     Final
