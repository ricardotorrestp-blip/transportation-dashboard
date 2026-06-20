# Modelo de Datos — Star Schema

## Diagrama de Relaciones

```
                    ┌──────────────┐
                    │ DIM_Calendar │
                    │──────────────│
                    │ DateKey (PK) │
                    │ Year         │
                    │ Month        │
                    │ MonthName    │
                    │ WeekNum      │
                    │ WeekLabel    │
                    │ Quarter      │
                    │ IsCurrentWk  │
                    │ IsCurrentMo  │
                    └──────┬───────┘
                           │ 1:N
    ┌──────────────┐  ┌────┴──────────────┐  ┌─────────────────┐
    │ DIM_Planta   │  │   FACT_Cargas     │  │ DIM_Carrier     │
    │──────────────│  │───────────────────│  │─────────────────│
    │ PlantaKey    │──│ PlantaKey (FK)    │──│ CarrierKey (PK) │
    │ PlantaName   │  │ DateKey (FK)      │  │ CarrierName     │
    │ Ciudad       │  │ CarrierKey (FK)   │  │ CarrierType     │
    │ Region       │  │ ModoKey (FK)      │  └─────────────────┘
    │ Pais         │  │ ClienteKey (FK)   │
    └──────────────┘  │ LoadID            │  ┌─────────────────────┐
                      │ Status            │  │ DIM_ModoTransporte  │
                      │ PlannedPallets    │  │─────────────────────│
                      │ ActualPallets     │──│ ModoKey (PK)        │
                      │ MaxPallets        │  │ ModoName            │
                      │ Saturation        │  │ ModoGroup           │
                      │ UnitType          │  └─────────────────────┘
                      │ TotalChargeUSD    │
                      │ IsOnTime (1/0)    │  ┌─────────────────┐
                      │ IsInFull (1/0)    │  │ DIM_Cliente     │
                      └────┬──────────────┘  │─────────────────│
                           │                 │ ClienteKey (PK) │
                           │              ┌──│ ClienteName     │
    ┌──────────────────────┴───┐          │  │ Segment         │
    │    FACT_CostosPlan       │          │  └─────────────────┘
    │──────────────────────────│          │
    │ PlantaKey (FK)           │          │
    │ DateKey (FK)             │          │
    │ ModoKey (FK)             │          │
    │ BP2026_KUSD              │          │
    │ Actual_Sensitivity_KUSD  │          │
    └──────────────────────────┘          │
                                          │
    ┌──────────────────────────┐          │
    │    FACT_GR_Status        │          │
    │──────────────────────────│          │
    │ PlantaKey (FK)           │          │
    │ DateKey (FK)             │          │
    │ Sensitivity_Std_KUSD     │          │
    │ GR_KUSD                  │          │
    │ MissingGR_KUSD           │          │
    │ Commitment_KUSD          │          │
    │ Accrual_KUSD             │          │
    └──────────────────────────┘
                                          
    ┌──────────────────────────┐          
    │    FACT_PremiumFreight   │          
    │──────────────────────────│          
    │ PlantaKey (FK)           │          
    │ DateKey (FK)             │──────────┘
    │ ClienteKey (FK)          │
    │ PF_KUSD                  │
    │ Motivo                   │
    └──────────────────────────┘

    ┌──────────────────────────┐
    │    FACT_Demurrages       │
    │──────────────────────────│
    │ PlantaKey (FK)           │
    │ DateKey (FK)             │
    │ CarrierKey (FK)          │
    │ Horas                    │
    │ Costo_KUSD               │
    └──────────────────────────┘
```

## Relaciones

| Desde | Hacia | Cardinalidad | Columna |
|-------|-------|-------------|---------|
| FACT_Cargas | DIM_Calendar | N:1 | DateKey |
| FACT_Cargas | DIM_Planta | N:1 | PlantaKey |
| FACT_Cargas | DIM_Carrier | N:1 | CarrierKey |
| FACT_Cargas | DIM_ModoTransporte | N:1 | ModoKey |
| FACT_Cargas | DIM_Cliente | N:1 | ClienteKey |
| FACT_CostosPlan | DIM_Calendar | N:1 | DateKey |
| FACT_CostosPlan | DIM_Planta | N:1 | PlantaKey |
| FACT_CostosPlan | DIM_ModoTransporte | N:1 | ModoKey |
| FACT_GR_Status | DIM_Calendar | N:1 | DateKey |
| FACT_GR_Status | DIM_Planta | N:1 | PlantaKey |
| FACT_Demurrages | DIM_Calendar | N:1 | DateKey |
| FACT_Demurrages | DIM_Planta | N:1 | PlantaKey |
| FACT_Demurrages | DIM_Carrier | N:1 | CarrierKey |
| FACT_PremiumFreight | DIM_Calendar | N:1 | DateKey |
| FACT_PremiumFreight | DIM_Planta | N:1 | PlantaKey |
| FACT_PremiumFreight | DIM_Cliente | N:1 | ClienteKey |

## Notas de Diseño

- **Granularidad FACT_Cargas**: 1 fila = 1 carga (LoadID). Es la tabla más granular.
- **Granularidad FACT_CostosPlan**: 1 fila = 1 planta × 1 mes × 1 modo. Datos del BP2026 y sensitivity.
- **Granularidad FACT_GR_Status**: 1 fila = 1 planta × 1 semana. Tracking acumulativo de GR vs plan.
- **Modos de Transporte**: MX-MX, US-US, Ocean, Cross Border, 4PL.
- **IsOnTime / IsInFull**: Flags calculados en Power Query para derivar OTIF en DAX.
