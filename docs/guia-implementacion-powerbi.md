# Guía de Implementación en Power BI

## Paso 0: Preparar archivos

1. Copiar `templates/captura-semanal.xlsx` a una carpeta compartida (OneDrive/SharePoint)
2. Tener a la mano `NAM Transportation Dashboard June 2026.xlsx` como fuente del BP
3. Tener el raw data operativo (`Juarez pilot week 9.xlsx` o equivalente)

---

## Paso 1: Crear el archivo .pbix

1. Abrir **Power BI Desktop**
2. **Archivo → Nuevo**
3. Guardar como `Transportation_Dashboard.pbix` en la carpeta del proyecto

---

## Paso 2: Aplicar el tema visual

1. **Vista → Temas → Examinar temas**
2. Seleccionar `theme-flujo-operativo.json` del repo
3. Esto aplica automáticamente:
   - Fondo slate (#F1F5F9)
   - Cards blancos con bordes redondeados y sombra
   - Paleta azul/ámbar/rojo/verde
   - Tipografía Segoe UI consistente

---

## Paso 3: Cargar las queries M (Power Query)

Para **cada archivo .m** en `power-query/`:

1. **Inicio → Transformar datos** (abre Power Query Editor)
2. **Nuevo origen → Consulta en blanco**
3. Click derecho en la consulta → **Editor avanzado**
4. Borrar el contenido y **pegar el código M** del archivo correspondiente
5. Renombrar la consulta con el nombre de la tabla

### Orden recomendado de carga

| # | Archivo | Nombre en Power BI | Tipo |
|---|---------|-------------------|------|
| 1 | `dim-calendario.m` | DIM_Calendar | Dimensión |
| 2 | `dim-planta.m` | DIM_Planta | Dimensión |
| 3 | `dim-modo-transporte.m` | DIM_ModoTransporte | Dimensión |
| 4 | `dim-cliente.m` | DIM_Cliente | Dimensión |
| 5 | `dim-carrier.m` | DIM_Carrier | Dimensión |
| 6 | `fact-cargas.m` | FACT_Cargas | Fact |
| 7 | `fact-costos-plan.m` | FACT_CostosPlan | Fact |
| 8 | `fact-gr-status.m` | FACT_GR_Status | Fact |
| 9 | `fact-demurrages.m` | FACT_Demurrages | Fact |
| 10 | `fact-premium-freight.m` | FACT_PremiumFreight | Fact |

### Parámetros requeridos

Antes de cargar las fact tables, crear estos **parámetros** en Power Query:

1. **Inicio → Administrar parámetros → Nuevo parámetro**

| Parámetro | Tipo | Valor ejemplo |
|-----------|------|---------------|
| `FolderPath` | Texto | `C:\Users\Surface\transportation-dashboard\templates` |
| `NAMDashboardPath` | Texto | `C:\Users\Surface\Downloads\NAM Transportation Dashboard June 2026.xlsx` |

2. Ajustar las rutas según tu entorno
3. Click **Cerrar y aplicar**

---

## Paso 4: Configurar relaciones

1. Ir a **Vista de modelo** (ícono de diagrama en el panel izquierdo)
2. Power BI detectará algunas relaciones automáticamente
3. Verificar/crear manualmente estas relaciones:

```
FACT_Cargas[DateKey]        →  DIM_Calendar[DateKey]       (N:1)
FACT_Cargas[PlantaKey]      →  DIM_Planta[PlantaKey]       (N:1)
FACT_Cargas[CarrierName]    →  DIM_Carrier[CarrierName]    (N:1)
FACT_Cargas[ModoKey]        →  DIM_ModoTransporte[ModoKey] (N:1)
FACT_Cargas[ClienteKey]     →  DIM_Cliente[ClienteKey]     (N:1)

FACT_CostosPlan[DateKey]    →  DIM_Calendar[DateKey]       (N:1)
FACT_CostosPlan[PlantaKey]  →  DIM_Planta[PlantaKey]       (N:1)
FACT_CostosPlan[ModoKey]    →  DIM_ModoTransporte[ModoKey] (N:1)

FACT_GR_Status[PlantaKey]   →  DIM_Planta[PlantaKey]       (N:1)
FACT_Demurrages[PlantaKey]  →  DIM_Planta[PlantaKey]       (N:1)
FACT_PremiumFreight[PlantaKey] → DIM_Planta[PlantaKey]     (N:1)
```

4. **Dirección del filtro cruzado**: Única (de dimensión a fact)
5. Organizar las tablas visualmente: dimensiones arriba, facts abajo

---

## Paso 5: Crear tablas auxiliares

En **Vista de datos**, crear estas tablas con DAX:

### Tabla WaterfallCategory
```dax
WaterfallCategory = 
DATATABLE(
    "Category", STRING,
    "SortOrder", INTEGER,
    {
        {"GR", 1},
        {"Commitment", 2},
        {"Accruals", 3},
        {"Forecast", 4},
        {"Budget", 5}
    }
)
```

### Tabla AUX_Ventas
Conectar desde la hoja "Ventas" del template (ya está en la query si se usa `fact-cargas.m` con FolderPath), o crear manual:
```dax
AUX_Ventas = 
DATATABLE(
    "PlantaKey", STRING,
    "MonthLabel", STRING,
    "Ventas_KUSD", DOUBLE,
    {
        {"TOL", "Jun 2026", 2500},
        {"JUP1", "Jun 2026", 2200},
        {"JUP2", "Jun 2026", 1800}
    }
)
```

### What-If Parameter: Target Freight %
1. **Modelado → Nuevo parámetro → What-If**
2. Nombre: `Target Freight %`
3. Mínimo: 0.05, Máximo: 0.10, Incremento: 0.005, Default: 0.075
4. Esto crea automáticamente la tabla y la medida

---

## Paso 6: Crear las medidas DAX

1. Crear una **tabla de medidas** vacía:
   ```dax
   _Medidas = ROW("x", 0)
   ```
2. Ocultar esta tabla de las visualizaciones
3. Copiar cada medida de los archivos `dax-measures/`:

| Archivo | Medidas principales |
|---------|--------------------|
| `01-operaciones.dax` | OTIF %, Avg Saturation, Saturation Status |
| `02-costos.dax` | Total Spend KUSD, Weekly Run Rate, BP Variance, Cost per Pallet |
| `03-financial.dax` | Waterfall Value, Forecast Cielo Propuesto, Forecast Status |
| `04-pnl.dax` | Freight Pct of Sales, EBITDA Impact, Savings Opportunity |

4. Para crear cada medida: Click derecho en `_Medidas` → **Nueva medida** → pegar el DAX

---

## Paso 7: Construir las páginas

### Estética del TSX (causa-efecto con bordes de color)

Cada bloque/sección usa un **rectángulo de fondo** con borde izquierdo de color:

| Página | Color borde izq. | Hex |
|--------|------------------|-----|
| P1: Executive | — | — |
| P2: Operaciones | Azul | #3B82F6 |
| P3: Costos | Ámbar | #F59E0B |
| P4: Financial | Indigo | #6366F1 |
| P5: P&L | Esmeralda | #10B981 |

**Para replicar el borde lateral del TSX:**
1. Insertar → Formas → Rectángulo
2. Tamaño: ancho=4px, alto=el alto de la sección
3. Color de relleno: el color del bloque
4. Sin borde
5. Posicionar al borde izquierdo de la sección
6. Enviar al fondo

**Para el badge numérico (01, 02, 03, 04):**
1. Insertar → Cuadro de texto
2. Texto: "01" con fondo circular del color correspondiente
3. O usar un rectángulo redondeado pequeño + texto encima

### P1: Executive Summary (ver `docs/dashboard-pages.md`)

```
Componentes:
├── Slicer bar (arriba): Planta, Año, Mes
├── KPI Cards (fila): OTIF%, Cargas, Forecast, BP Var, Freight%Sales
├── Stacked Bar: BP vs Actual por planta (visual nativo)
├── Donut: Mix por modo de transporte
├── Line Chart: Weekly run rate por planta
└── Table: Top 5 riesgos
```

### P2: Operaciones (borde azul #3B82F6)

```
Componentes:
├── Gauge: OTIF % (target=95%, warning=90%)
│   Formato: Colores condicionales, fuente 28pt
├── Card group: Viajes Completados / En Tránsito
│   Usar íconos ✅ 🚛 como prefijo en el título
├── Table con formato condicional: Matriz de Riesgos
│   Rojo para background, valores en negrita
├── Combo Chart: Saturation (barras) + Spend (línea) por semana
│   Eje X = WeekLabel, eje Y1 = Saturation, eje Y2 = TotalChargeUSD
├── Clustered Bar: Planned vs Actual Pallets por Location
└── Table: Demurrages por Carrier (horas + costo)
```

### P3: Costos (borde ámbar #F59E0B)

```
Componentes:
├── Card: Costo Semana Actual ($115K) — fondo slate-50
├── Card: Proyección Semana Siguiente ($128K) — fondo ámbar-50
│   Subtítulo con flecha ↑ y porcentaje
├── Area Chart: Weekly Spend Trend
│   Agregar Constant Line para BP semanal promedio
├── 100% Stacked Bar: Spend por Modo
└── Table: Cost per Pallet por Carrier con sparkline WoW
```

### P4: Financial (borde indigo #6366F1)

```
Componentes:
├── KPI Cards: Budget | Forecast | Varianza (con formato condicional rojo/verde)
├── Progress Bar: GR Completion % (usar Gauge horizontal)
├── Waterfall Chart (visual nativo de Power BI):
│   Categoría = WaterfallCategory[Category], Valor = [Waterfall Value KUSD]
│   Marcar "Budget" como Total, "Forecast" como Total
├── Line Chart: GR Acumulado vs Sensitivity Std por CW
└── Table: GR Status semanal con Missing GR en rojo
```

### P5: P&L (borde esmeralda #10B981)

```
Componentes:
├── Card oscuro (fondo #0F172A): Ventas Estimadas + Forecast Cost
├── Card: Freight % of Sales (formato condicional: >7.5% = rojo)
├── Card: EBITDA Impact (rojo si negativo, verde si positivo)
├── Combo Chart: BP vs Actual YTD (barras) + Freight % (línea)
├── Treemap: Premium Freight por Cliente
└── Card: Total Savings Opportunity
```

---

## Paso 8: Formato condicional (replicar semáforos del TSX)

Para cada KPI card que necesita semáforo:

1. Seleccionar visual → **Formato → Etiquetas de datos → Color**
2. Click **fx** (formato condicional)
3. Configurar reglas:

| Medida | Verde | Amarillo | Rojo |
|--------|-------|----------|------|
| OTIF % | ≥ 95% | 90-95% | < 90% |
| Forecast Status | On Track | At Risk | Over Budget |
| Freight % Sales | ≤ 7.5% | 7.5-8.5% | > 8.5% |
| EBITDA Impact | ≥ 0 | — | < 0 |
| Saturation | ≥ 90% | 75-90% | < 75% |

---

## Paso 9: Header sticky (replicar TSX)

El header del TSX es sticky con forecast total. En Power BI:

1. Crear un **rectángulo blanco** en la parte superior (0,0 a ancho completo × 80px)
2. Agregar sombra inferior sutil
3. Colocar encima:
   - Título "Flujo Operativo-Financiero" (izquierda)
   - Subtítulo "Causa y efecto: De la ejecución operativa al impacto en P&L"
   - Card con Forecast total (derecha), con color condicional

---

## Paso 10: Publicar

1. **Archivo → Publicar → Power BI Service**
2. Seleccionar workspace
3. Configurar **Scheduled Refresh** (si usas gateway para archivos locales)
4. Compartir el link del dashboard

---

## Checklist Final

- [ ] Tema aplicado (slate background, cards blancos redondeados)
- [ ] 5 dimensiones cargadas
- [ ] 5 fact tables cargadas
- [ ] Relaciones configuradas (Vista de modelo)
- [ ] Tablas auxiliares creadas (Waterfall, Ventas, Target %)
- [ ] ~45 medidas DAX creadas
- [ ] 5 páginas construidas con layout del wireframe
- [ ] Bordes laterales de color por bloque
- [ ] Badges numéricos (01-04) en cada sección
- [ ] Formato condicional (semáforos) en KPIs
- [ ] Header con Forecast total
- [ ] Slicers funcionales (Planta, Año, Mes, Semana)
- [ ] Publicado al Power BI Service
