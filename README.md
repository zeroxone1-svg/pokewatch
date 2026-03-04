# ⌚ PokéWatch — Atrapa Pokémon caminando

Esta versión incluye las dos generaciones (Kanto + Johto) y la lógica de balance actualizada. Este documento resume tanto la experiencia de juego como las reglas técnicas implementadas en el código fuente.

---

## Resumen técnico (rápido)

- Gen 1 (Kanto) y Gen 2 (Johto) están integradas en `source/PokemonData.mc` (251 entradas).
- Las reglas globales de spawn, XP, shiny, daño por pasos y bonus de actividad están centralizadas en `source/BalanceConfig.mc` y `source/SpawnEngine.mc`.
- Los legendarios por misión (Articuno, Zapdos, Moltres, Mewtwo, Mew, Raikou, Entei, Suicune, Lugia, Ho-Oh, Celebi) se controlan en `source/LegendaryQuestManager.mc`.

---

## Mecánicas de juego

### Presets de dificultad

El juego tiene 3 presets. El preset activo es **Medium** (`ACTIVE_PRESET = PRESET_MEDIUM`).

| Parámetro | Casual | **Medium** | Challenging |
|---|---|---|---|
| Pasos por spawn | 400 | **500** | 750 |
| Prob. de spawn exitoso | 80% | **70%** | 60% |
| Prob. shiny | 1/360 | **1/450** | 1/600 |
| Variación HP | ±15% | **±20%** | ±25% |
| Pasos por bloque actividad | 500 | **600** | 700 |
| Bloques mín. para bonus | 2 | **2** | 3 |
| Bonus actividad (tiers 2-3) | +60% | **+50%** | +45% |
| Divisor costo evolución | /4 | **/3** | /2 |

---

### Probabilidad de aparición por tier (spawn)

Cada **500 pasos** se intenta un spawn. Si el roll es exitoso (70% en Medium), se elige un Pokémon del pool ponderado:

| Tier | Categoría | Peso | Prob. aprox. | HP base (pasos) |
|---|---|---|---|---|
| 0 | Común | 55 | ~55% | 400 – 600 |
| 1 | Poco común | 25 | ~25% | 700 – 1,000 |
| 2 | Raro | 12 | ~12% | 1,200 – 1,800 |
| 3 | Muy raro | 6 | ~6% | 2,500 – 4,000 |
| 4 | Legendario | 2 | ~2% | 5,000 – 12,000 |

- **Pokémon del día**: tiene **3x** más peso en el pool de spawn.
- **Bonus de actividad**: si llevas ≥ 2 bloques de actividad (1,200+ pasos), los tiers 2 y 3 reciben **+50%** de peso extra, y el poder de paso sube a **115%**.
- Solo aparecen formas base (no evolucionadas) — las evoluciones se obtienen capturando duplicados.
- Los legendarios de quest **nunca** aparecen por spawn normal.

---

### Combate — Daño por pasos

Cada Pokémon tiene un HP base según su tier. Al encontrar un Pokémon:

1. El HP se ajusta con variación aleatoria de **±20%**.
2. **Cada paso que caminas = 1 de daño** (o 1.15 con bonus de actividad).
3. Cuando el HP llega a 0, el Pokémon es capturado.

| Ejemplo | Tier | HP base | Pasos para capturar (aprox.) |
|---|---|---|---|
| Caterpie | 0 | 400 | ~320 – 480 pasos |
| Sandslash | 1 | 800 | ~640 – 960 pasos |
| Pikachu | 2 | 1,500 | ~1,200 – 1,800 pasos |
| Venusaur | 3 | 3,000 | ~2,400 – 3,600 pasos |
| Dragonite | 4 | 10,000 | ~8,000 – 12,000 pasos |

---

### Shiny

- Probabilidad: **1 en 450** por encuentro (Medium).
- Se aplica tanto a spawns normales como a legendarios.

---

### Sistema de XP y Niveles

Cada Pokémon capturado gana XP. El nivel máximo es **100**.

#### XP por captura (se otorga al Pokémon capturado)

| Tier | XP por captura |
|---|---|
| 0 — Común | 200 XP |
| 1 — Poco común | 350 XP |
| 2 — Raro | 500 XP |
| 3 — Muy raro | 800 XP |
| 4 — Legendario | 1,500 XP |

#### XP necesaria por nivel (varía según tier)

| Tier | XP/nivel | Capturas para Lv.10 | Capturas para Lv.25 |
|---|---|---|---|
| 0 — Común | 100 XP | ~5 | ~12 |
| 1 — Poco común | 200 XP | ~6 | ~14 |
| 2 — Raro | 350 XP | ~7 | ~17 |
| 3 — Muy raro | 550 XP | ~7 | ~17 |
| 4 — Legendario | 800 XP | ~5 | ~13 |

> Fórmula: `Nivel = 1 + (XP total / XP por nivel)`, máx 100.

#### Buddy XP (bonus por capturar de la misma familia)

| Tier | Buddy bonus XP |
|---|---|
| 0 — Común | 150 XP |
| 1 — Poco común | 250 XP |
| 2 — Raro | 400 XP |
| 3 — Muy raro | 600 XP |
| 4 — Legendario | 1,000 XP |

---

### Evolución

Para evolucionar un Pokémon necesitas cumplir **dos condiciones**:

1. **Nivel mínimo** (según el evoCost base del Pokémon)
2. **Capturas suficientes** del mismo Pokémon (evoCost / 3 en Medium, mínimo 3)

#### Niveles de evolución

| evoCost base | Nivel requerido | Ejemplos |
|---|---|---|
| ≤ 25 | Lv. 7 | Caterpie, Weedle, Pidgey, Rattata |
| ≤ 50 | Lv. 18 | Ivysaur, Nidorina, Gloom, Haunter |
| ≤ 100 | Lv. 25 | Pikachu, Eevee, Kadabra |
| ≤ 150 | Lv. 40 | Dragonair |
| > 150 (400) | Lv. 20 | Magikarp → Gyarados |

#### Capturas requeridas para evolucionar (Medium, divisor /3, mín. 3)

| evoCost base | Capturas necesarias | Ejemplos |
|---|---|---|
| 25 | 9 | Caterpie, Pidgey, Rattata |
| 50 | 17 | Ivysaur, Ekans, Nidorina |
| 100 | 34 | Pikachu, Eevee, Abra→Kadabra |
| 150 | 50 | Dragonair→Dragonite |
| 400 | 134 | Magikarp → Gyarados |

#### Evoluciones ramificadas

Algunos Pokémon tienen múltiples evoluciones posibles (se elige al azar):

| Pokémon | Evoluciones posibles |
|---|---|
| Eevee | Vaporeon, Jolteon, Flareon, Espeon, Umbreon |
| Gloom | Vileplume, Bellossom |
| Poliwhirl | Poliwrath, Politoed |
| Slowpoke | Slowbro, Slowking |
| Tyrogue | Hitmonlee, Hitmonchan, Hitmontop |

#### Ejemplos completos de evolución

| Pokémon | Tier | Nivel req. | Capturas req. | XP total necesaria |
|---|---|---|---|---|
| Caterpie → Metapod | 0 | Lv. 7 | 9 | 600 XP |
| Nidorina → Nidoqueen | 1 | Lv. 18 | 17 | 3,400 XP |
| Pikachu → Raichu | 2 | Lv. 25 | 34 | 8,400 XP |
| Dragonair → Dragonite | 3 | Lv. 40 | 50 | 21,450 XP |
| Magikarp → Gyarados | 0 | Lv. 20 | 134 | 1,900 XP |

---

### Legendarios — Misiones de quest

Los legendarios **no** aparecen por spawn normal. Se desbloquean cumpliendo misiones específicas:

#### Gen 1 — Kanto

| Pokémon | Condición | Estimación |
|---|---|---|
| Articuno (#144) | 500,000 pasos totales acumulados | ~2 meses caminando |
| Zapdos (#145) | Racha de 30 días activos consecutivos | 1 mes de racha |
| Moltres (#146) | 500 capturas totales individuales | — |
| Mewtwo (#150) | Capturar los 146 Pokémon normales de Kanto | Excluye los 5 legendarios quest |
| Mew (#151) | Capturar Articuno + Zapdos + Moltres | Después de los 3 pájaros |

#### Gen 2 — Johto

| Pokémon | Condición | Estimación |
|---|---|---|
| Raikou (#243) | 20,000 pasos en un solo día (req. 50K totales previos) | Día muy activo |
| Entei (#244) | 1,000,000 pasos totales acumulados | ~4 meses caminando |
| Suicune (#245) | Racha de 60 días activos consecutivos | 2 meses de racha |
| Lugia (#249) | Capturar Raikou + Entei + Suicune | Después de las 3 bestias |
| Ho-Oh (#250) | Completar Pokédex Kanto (151 especies) | Incluye legendarios quest |
| Celebi (#251) | Capturar todas las especies normales (ambas gen) | 240 especies normales |

---

### Bloques de actividad

El juego premia caminar consistentemente:

- Cada **600 pasos** consecutivos en un día = 1 bloque de actividad.
- Con **≥ 2 bloques** (1,200+ pasos) se activa el **bonus de actividad**:
  - Tiers 2-3 reciben **+50%** de peso en el pool de spawn.
  - El spawn roll tiene **+10%** más probabilidad de éxito (80% en vez de 70%).
  - El poder de paso sube a **115%** (capturas más rápidas).

---

### Racha diaria

- Jugar (dar pasos) en un día cuenta como día activo.
- Días consecutivos activos incrementan la racha (`dailyStreak`).
- La racha es necesaria para desbloquear a Zapdos (30 días) y Suicune (60 días).

---

## Diferencias Kanto vs Johto (qué cambia y qué no)

- Lo que NO cambia entre generaciones: la mecánica de spawn, la fórmula de daño por pasos, las bonificaciones por actividad, las probabilidades de shiny y el sistema de XP/levels. Esas reglas son globales y se encuentran en `source/BalanceConfig.mc` y `source/SpawnEngine.mc`.
- Lo que SÍ cambia: los valores por Pokémon, que determinan rareza (`:tier`), HP base (`:hp`) y `:evoCost`. Esos valores se definen por entrada en `source/PokemonData.mc`. Por ejemplo, muchos Pokémon de Johto tienen tiers y HP distintos a sus contrapartes de Kanto.

En otras palabras: Johto no tiene un sistema separado — usa las mismas mecánicas; las diferencias aparecen porque cada Pokémon tiene sus parámetros propios en `PokemonData`.

---

## Dónde ver/ajustar parámetros de gameplay

- `source/BalanceConfig.mc`: spawn thresholds, tier weights, shiny odds, XP por tier, activity bonus, variaciones de HP.
- `source/PokemonData.mc`: lista completa de 251 Pokémon con `:tier`, `:hp`, `:evoCost`, `:evoTo`.
- `source/SpawnEngine.mc`: lógica de selección ponderada, pool de spawn, aplicación de bonificaciones y generación de encuentros.
- `source/LegendaryQuestManager.mc`: condiciones para desbloquear legendarios.

---

## Ejecutar la compilación / simulación local

Para compilar y ejecutar la simulación en el emulador (Windows):

```powershell
C:/Users/Alonso/AppData/Roaming/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa/bin/monkeyc.bat -o bin/pokewatch.prg -f monkey.jungle -y developer_key -d vivoactive6 -w
Start-Sleep -Seconds 5; C:/Users/Alonso/AppData/Roaming/Garmin/ConnectIQ/Sdks/connectiq-sdk-win-8.4.1-2026-02-03-e9f77eeaa/bin/monkeydo.bat bin/pokewatch.prg vivoactive6
```

O usar la tarea integrada de VS Code: `Garmin: Build PokeWatch` (group build).

---
