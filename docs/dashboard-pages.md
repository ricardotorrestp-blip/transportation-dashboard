# Dashboard Pages — Layout Specification

## Navegación

Todas las páginas comparten:
- **Slicer bar superior**: Planta | Año | Mes | Semana
- **Header**: Logo + Título + Forecast total (KPI card con semáforo)
- **Tema**: Slate/Blue profesional (colores del TSX)

---

## P1: Executive Summary

> Vista consolidada de todas las plantas. El gerente regional ve todo en una pantalla.

```
┌─────────────────────────────────────────────────────────────────┐
│  [Planta ▾]  [Año ▾]  [Mes ▾]                                  │
├──────────┬──────────┬──────────┬──────────┬─────────────────────┤
│ OTIF %   │ Cargas   │ Forecast │ BP Var   │ Freight % Sales     │
│  86%     │  200     │ $522K    │ +$22K    │ 8.0%                │
│  ⚠️      │          │  🔴      │  🔴      │ 🔴 (>7.5%)          │
├──────────┴──────────┴──────────┴──────────┴─────────────────────┤
│                                                                  │
│  [Stacked Bar: BP vs Actual por Planta]     [Donut: Mix por     │
│   TOL ████░░  JUP1 ████████░  JUP2 ████░    Modo de Transporte]│
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Line: Weekly Run Rate      │  [Table: Top 5 Riesgos           │
│   trending por planta]       │   con impacto financiero]        │
└──────────────────────────────┴───────────────────────────────────┘
```

---

## P2: Operaciones & Riesgo

> Drill-down operativo. Causa raíz de desviaciones.

```
┌─────────────────────────────────────────────────────────────────┐
│  01  OPERACIONES Y RIESGOS                                      │
├───────────────┬───────────────┬──────────────────────────────────┤
│               │               │                                  │
│  OTIF Gauge   │ Estatus       │  Matriz de Riesgos              │
│  ┌───────┐    │ Viajes        │  ┌────────────────────────────┐ │
│  │  86%  │    │ ✅ 142 Compl. │  │ Demoras Frontera   $45K   │ │
│  └───────┘    │ 🚛  58 Trán.  │  │ Diesel Surcharge   $25K   │ │
│               │               │  │ Disputas           $12K   │ │
│  <90% = alert │               │  │ ────────────────────────── │ │
│               │               │  │ Total Accruals     $82K   │ │
│               │               │  └────────────────────────────┘ │
├───────────────┴───────────────┴──────────────────────────────────┤
│                                                                  │
│  [Combo Chart: Saturation bars + Spend line por semana]          │
│   Como el PNG actual pero con cost-per-pallet overlay            │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Clustered Bar:             │  [Table: Demurrages por Carrier  │
│   Planned vs Actual Pallets  │   con horas acumuladas y costo]  │
│   por Location]              │                                  │
└──────────────────────────────┴───────────────────────────────────┘
```

---

## P3: Costo & Sensibilidad

> Visión semanal del gasto y proyección a corto plazo.

```
┌─────────────────────────────────────────────────────────────────┐
│  02  SENSIBILIDAD CORTO PLAZO                                   │
├──────────────────────────────┬───────────────────────────────────┤
│                              │                                   │
│  Costo Semana Actual         │  Proyección Semana Siguiente      │
│  ┌──────────────────┐        │  ┌──────────────────────────┐    │
│  │    $115.0K        │        │  │    $128.0K  ↑+11.3%      │    │
│  │    Causado L-D    │        │  │    Por volumen en trán.   │    │
│  └──────────────────┘        │  └──────────────────────────┘    │
│                              │                                   │
├──────────────────────────────┴───────────────────────────────────┤
│                                                                  │
│  [Area Chart: Weekly Spend Trend con BP reference line]          │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [100% Stacked Bar:          │  [Table: Cost per Pallet         │
│   Spend Mix por Modo         │   por Carrier con WoW trend]     │
│   MXMX | USUS | Ocean | CB] │                                  │
└──────────────────────────────┴───────────────────────────────────┘
```

---

## P4: Financial Performance

> Waterfall de GR → Commitment → Accruals = Forecast vs Budget.

```
┌─────────────────────────────────────────────────────────────────┐
│  03  FINANCIAL PERFORMANCE (MENSUAL)                            │
├──────────┬──────────┬──────────┬────────────────────────────────┤
│ Budget   │ Forecast │ Varianza │                                │
│ $500K    │ $522K    │ +$22K 🔴 │  GR Completion: 87% ████████░ │
├──────────┴──────────┴──────────┴────────────────────────────────┤
│                                                                  │
│  WATERFALL CHART                                                 │
│  ┌──────┐                                                       │
│  │ GR   │ $280K  ██████████████████████████                     │
│  │      │        ├──────────────────────────┤                    │
│  │ Comm │ $160K  ░░░░░░░░░░░░░░░█████████████                  │
│  │      │        ├─────────────────────────────────┤             │
│  │ Accr │  $82K  ░░░░░░░░░░░░░░░░░░░░░░░░░████████             │
│  │      │                                    ▼                   │
│  │ FCST │ $522K  ████████████████████████████████████  ← Total  │
│  │      │                          │ ← Budget $500K line        │
│  └──────┘                                                       │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Line: GR Acumulado vs      │  [Table: GR Status por Semana   │
│   Sensitivity Std por CW]    │   con Missing GR highlight]      │
└──────────────────────────────┴───────────────────────────────────┘
```

---

## P5: P&L Impact

> Conexión final con estado de resultados.

```
┌─────────────────────────────────────────────────────────────────┐
│  04  IMPACTO EN P&L                                             │
├─────────────────────┬───────────────────┬───────────────────────┤
│                     │                   │                       │
│  Ventas Estimadas   │ Freight % Sales   │ EBITDA Impact         │
│  ┌───────────────┐  │ ┌───────────────┐ │ ┌───────────────────┐│
│  │   $6.5M       │  │ │   8.0%        │ │ │   -$35K           ││
│  │               │  │ │ Target: 7.5%  │ │ │ Erosionando margen││
│  │  Forecast:    │  │ │   🔴          │ │ │   🔴              ││
│  │  $522K cost   │  │ │               │ │ │                   ││
│  └───────────────┘  │ └───────────────┘ │ └───────────────────┘│
├─────────────────────┴───────────────────┴───────────────────────┤
│                                                                  │
│  [Combo: BP vs Actual YTD bars + Freight % line]                │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Treemap: Premium Freight   │  [KPI Card: Savings Opportunity  │
│   por Cliente OEM]           │   Saturación + EBITDA gap]       │
│   GM ████  BMW ███           │                                  │
│   TSLA ██  STLA █            │   Potential: $47K               │
└──────────────────────────────┴───────────────────────────────────┘
```

---

## Tablas Auxiliares Requeridas en Power BI

1. **WaterfallCategory**: tabla desconectada con valores `GR`, `Commitment`, `Accruals`, `Forecast`, `Budget` para el waterfall chart.
2. **AUX_Ventas**: tabla con `PlantaKey`, `MonthLabel`, `Ventas_KUSD` — alimentada desde la hoja Ventas del template.
3. **Target Freight %**: What-If parameter (slider 5%-10%, default 7.5%).
