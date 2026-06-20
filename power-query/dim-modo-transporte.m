let
    Source = Table.FromRows(
        {
            {"MXMX",  "MX-MX",        "Domestic",  "Road"},
            {"USUS",  "US-US",         "Domestic",  "Road"},
            {"OCN",   "Ocean",         "International", "Sea"},
            {"CB",    "Cross Border",  "International", "Road"},
            {"4PL",   "4PL",           "Managed",   "Multi"}
        },
        {"ModoKey", "ModoName", "ModoGroup", "ModoType"}
    ),
    SetTypes = Table.TransformColumnTypes(Source, {
        {"ModoKey", type text},
        {"ModoName", type text},
        {"ModoGroup", type text},
        {"ModoType", type text}
    })
in
    SetTypes
