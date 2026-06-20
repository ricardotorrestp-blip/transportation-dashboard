# Transportation Dashboard — Contra-Propuesta

## Visión

Dashboard de Power BI que transforma el tracking estático (BP vs Actuals por planta) en un **flujo operativo-financiero de causa y efecto**: desde la ejecución operativa hasta el impacto en P&L.

### Diferenciadores vs Propuesta Regional (NAM Dashboard)

| Aspecto | NAM Dashboard | Esta Propuesta |
|---------|--------------|----------------|
| Estructura | Hojas por planta, tablas planas | Modelo relacional star-schema |
| Narrativa | Tracking mensual estático | Flujo causa-efecto en 4 bloques |
| Granularidad | Mensual + semanal manual | Drill-down dinámico (mes → semana → carga) |
| Financial | BP vs Actual simple | Waterfall GR → Commitment → Accruals + EBITDA impact |
| Saturación | Tabla de pallets | Visual con cost-per-pallet y tendencia |
| Riesgos | Demurrages acumuladas | Matriz de riesgos con impacto financiero cuantificado |
| Captura | Cada planta llena su Excel libre | Template estandarizado con validaciones |

## Arquitectura del Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  P1: Executive Summary (Todas las plantas)                  │
├─────────────────────────────────────────────────────────────┤
│  P2: Operaciones & Riesgo (OTIF, Volumen, Riesgos)         │
├─────────────────────────────────────────────────────────────┤
│  P3: Costo & Sensibilidad (Semanal, por modo, por carrier) │
├─────────────────────────────────────────────────────────────┤
│  P4: Financial Performance (Waterfall, GR Status, Forecast) │
├─────────────────────────────────────────────────────────────┤
│  P5: P&L Impact (Freight % Sales, EBITDA, Premium Freight)  │
└─────────────────────────────────────────────────────────────┘
```

## Estructura del Repo

```
├── README.md
├── docs/
│   └── data-model.md          # Star schema y relaciones
├── power-query/
│   ├── dim-calendario.m        # Dimensión Calendario
│   ├── dim-planta.m            # Dimensión Planta/Location
│   ├── dim-carrier.m           # Dimensión Carrier
│   ├── dim-modo-transporte.m   # Dimensión Modo (MX-MX, US-US, Ocean, CB)
│   ├── dim-cliente.m           # Dimensión Cliente (OEM)
│   ├── fact-cargas.m           # Fact Table: Cargas/Shipments
│   ├── fact-costos-plan.m      # Fact Table: Budget Plan (BP2026)
│   ├── fact-gr-status.m        # Fact Table: GR / Commitment tracking
│   ├── fact-demurrages.m       # Fact Table: Demoras/Penalizaciones
│   └── fact-premium-freight.m  # Fact Table: Premium Freight por cliente
├── dax-measures/
│   ├── 01-operaciones.dax      # OTIF, Volumen, Saturación
│   ├── 02-costos.dax           # Run-rate semanal, costo por modo
│   ├── 03-financial.dax        # Waterfall, GR, Commitment, Accruals
│   └── 04-pnl.dax              # Freight % Sales, EBITDA impact
├── templates/
│   └── captura-semanal.xlsx    # Template estandarizado de captura
```

## Modelo de Datos

Ver [docs/data-model.md](docs/data-model.md) para el diagrama completo del star schema.

## Cómo Usar

1. Llenar el template `templates/captura-semanal.xlsx` por planta/semana
2. En Power BI, conectar las queries M de `power-query/` a la carpeta de templates
3. Las medidas DAX de `dax-measures/` se copian al modelo
4. Publicar al Power BI Service para refresh automático
