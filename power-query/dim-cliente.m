let
    Source = Table.FromRows(
        {
            {"GM",    "General Motors", "OEM", "Automotive"},
            {"BMW",   "BMW",            "OEM", "Automotive"},
            {"STLA",  "Stellantis",     "OEM", "Automotive"},
            {"TSLA",  "Tesla",          "OEM", "Automotive"},
            {"OTHER", "Otros",          "Mixed", "Mixed"}
        },
        {"ClienteKey", "ClienteName", "Segment", "Industry"}
    ),
    SetTypes = Table.TransformColumnTypes(Source, {
        {"ClienteKey", type text},
        {"ClienteName", type text},
        {"Segment", type text},
        {"Industry", type text}
    })
in
    SetTypes
