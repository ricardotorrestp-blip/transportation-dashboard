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
│  [Grouped Bar: BP vs Sensitivity por Planta]                     │
│   TOL: BP ░░░░ Sens ████   JUP1: BP ░░░░░░ Sens ██████          │
│   (Consolidado — drill-through a P3 para ver por modo)          │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Stacked Bar: Sensitivity   │  [Table: Top 5 Riesgos           │
│   por Modo de Transporte     │   con impacto financiero]        │
│   MX-MX|US-US|Ocean|CB|4PL] │                                  │
├──────────────────────────────┤                                   │
│  [Line: Weekly Run Rate      │  [Donut: Mix % por Modo          │
│   trending por planta]       │   del Sensitivity total]         │
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
│  ★ GRÁFICA PRINCIPAL: BP vs Sensitivity por Modo (Mensual)      │
│  [Grouped Bar Chart — visual central]                            │
│                                                                  │
│   Eje X = DIM_Calendar[MonthName]                                │
│   Leyenda = DIM_ModoTransporte[ModoName]                         │
│   Valores = [BP por Modo KUSD] (barras outline/transparentes)    │
│             [Sensitivity por Modo KUSD] (barras sólidas)         │
│                                                                  │
│   Jan    Feb    Mar    Apr    May    Jun                          │
│   ┌──┐   ┌──┐   ┌──┐   ┌──┐   ┌──┐   ┌──┐                     │
│   │CB│   │CB│   │CB│   │CB│   │CB│   │CB│  ← Cross Border      │
│   │░░│   │░░│   │░░│   │░░│   │░░│   │░░│  ← Ocean             │
│   │▓▓│   │▓▓│   │▓▓│   │▓▓│   │▓▓│   │▓▓│  ← US-US            │
│   │██│   │██│   │██│   │██│   │██│   │██│  ← MX-MX             │
│   └──┘   └──┘   └──┘   └──┘   └──┘   └──┘                      │
│   ┌┄┄┐ = BP2026 (borde punteado, sin relleno)                   │
│   │██│ = Actual/Sensitivity (relleno sólido)                     │
│                                                                  │
│   Formato: Data labels con K USD, tooltip con varianza %         │
│   Colores por modo: MX-MX=#2563EB, US-US=#60A5FA,               │
│   Ocean=#F59E0B, CB=#10B981, 4PL=#8B5CF6                        │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Area Chart: Weekly Spend Trend con BP reference line]          │
│                                                                  │
├──────────────────────────────┬───────────────────────────────────┤
│  [Table: Varianza por Modo   │  [Table: Cost per Pallet         │
│   con semáforo y savings]    │   por Carrier con WoW trend]     │
│                              │                                   │
│  Modo     BP   Sens  Var %   │                                  │
│  MX-MX   280   288  +2.9% 🟡│                                  │
│  US-US    58    67  +15.5% 🔴│                                  │
│  Ocean    47    61  +29.8% 🔴│                                  │
│  CB      188   197  +4.8%  🟡│                                  │
│  4PL      20    20   0.0%  🟢│                                  │
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
