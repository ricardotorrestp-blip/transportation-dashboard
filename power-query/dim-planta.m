let
    Source = Table.FromRows(
        {
            {"TOL", "Toluca", "Toluca", "Estado de México", "MX", "NAM"},
            {"JUP1", "Juárez Planta 1", "Ciudad Juárez", "Chihuahua", "MX", "NAM"},
            {"JUP2", "Juárez Planta 2", "Ciudad Juárez", "Chihuahua", "MX", "NAM"}
        },
        {"PlantaKey", "PlantaName", "Ciudad", "Estado", "Pais", "Region"}
    ),
    SetTypes = Table.TransformColumnTypes(Source, {
        {"PlantaKey", type text},
        {"PlantaName", type text},
        {"Ciudad", type text},
        {"Estado", type text},
        {"Pais", type text},
        {"Region", type text}
    })
in
    SetTypes
