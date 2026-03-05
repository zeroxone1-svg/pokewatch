# PokeWatch — Plan de Sistema de Batallas, Equipo y Balance

> Documento de diseño para las nuevas mecánicas de combate contra entrenadores,
> gimnasios, sistema de equipo y curva de XP.
> Vivoactive 6 (360×360 AMOLED, touch, Connect IQ SDK 8.x)

---

## Estado actual del juego

### Lo que ya existe
- **251 Pokémon** (Gen 1 + Gen 2) con sprites individuales
- **Encuentros salvajes** cada 500 pasos (caminas → baja HP → captura)
- **Buddy system** (1 Pokémon acompañante que gana XP al caminar)
- **Evolución** por capturas + nivel mínimo
- **Legendarios por misión** (Articuno, Zapdos, Moltres, Mewtwo, Mew, bestias, etc.)
- **Sistema de XP** por captura y buddy walking
- **Pokédex + Profile views** con navegación swipe
- **Fondos dinámicos** por hora del día (4 fondos ruta + 1 batalla)
- **Sprites**: 251 Pokémon + bg_battle + 4 bg_route = 256 bitmaps totales

### Problemas identificados

#### 1. Curva de XP plana (PRIORIDAD ALTA)
**Archivo**: `source/BalanceConfig.mc` → `getLevelFromXP()`

La fórmula actual es **lineal**: `nivel = 1 + (xp / xpPerLevel)`

Esto significa que subir de Lv.1→2 cuesta exactamente lo mismo que de Lv.99→100.
Un Caterpie (tier 0, 100 XP/nivel) llega a Lv.100 con solo 9900 XP (~50 capturas).

**XP por nivel actual (constante)**:
| Tier | XP/nivel | Capturas para Lv.100 |
|------|----------|---------------------|
| 0 Común | 100 | ~50 |
| 1 Poco común | 200 | ~28 |
| 2 Raro | 350 | ~20 |
| 3 Muy raro | 550 | ~12 |
| 4 Legendario | 800 | ~8 |

Resultado: los Pokémon llegan a Lv.100 demasiado rápido. No hay sensación de progreso.

#### 2. Sin equipo — solo Buddy
**Archivo**: `source/GameState.mc`

Solo existe `buddyId` (1 Pokémon). No hay concepto de equipo de 6, ni selección
para combate.

#### 3. Sin modo batalla contra entrenadores/gimnasios
El único "combate" es caminar para bajar HP del Pokémon salvaje.

---

## Limitaciones técnicas del Vivoactive 6 + Connect IQ

| Recurso | Límite estimado | Uso actual |
|---------|-----------------|-----------|
| Heap (RAM app) | ~124 KB | DATA[251] + NAMES[251] + dictionaries = considerable |
| Storage (persistente) | ~28-64 KB | caughtCounts, pokemonXP, legendaryStatus, encounter, etc. |
| PRG (archivo app) | ~256 KB max | 251 sprites + 5 fondos = pesado |
| onUpdate() timeout | ~1-2 seg max | Cálculos complejos en draw = crash |

**Reglas de diseño**:
- Solo 1 bitmap cargado a la vez en RAM (loadResource on-demand, como ya funciona)
- Cálculos con enteros SIEMPRE (no floats)
- Lógica de batalla en timer callback, NUNCA en onUpdate
- Storage mínimo: usar tablas estáticas en código para todo lo que sea constante
- **0 sprites nuevos**: las batallas reusan los sprites de Pokémon existentes
- **0 persistencia de batalla**: si sales del app, la batalla se pierde sin penalización

---

## FASE 1: Curva XP exponencial

### Objetivo
Reemplazar la progresión lineal por una curva creciente tipo juegos originales.

### Diseño

**Fórmula nueva**: XP acumulado para nivel N = sumatoria de `base × n × sqrt(n) / 10` para n=1..N-1

Bases por tier: `[30, 55, 90, 140, 200]`

**Progresión resultante para Tier 0 (Común, base=30)**:
| Nivel | XP para este nivel | XP total acumulado |
|-------|-------------------|-------------------|
| 1→2 | 3 | 3 |
| 5→6 | 33 | 93 |
| 10→11 | 94 | 507 |
| 15→16 | 174 | 1,307 |
| 20→21 | 268 | 2,567 |
| 30→31 | 493 | 6,643 |
| 50→51 | 1,060 | 23,027 |
| 100 | — | ~178,000 |

**Satisfacción inmediata**: Los primeros niveles suben rápido (3, 8, 15, 24 XP).
**Progresión larga**: Lv.100 requiere dedicación real (~890 capturas tier 0).

### Archivos a modificar
- `source/BalanceConfig.mc`:
  - Reescribir `getXPForLevel(level, tier)` con curva exponencial
  - Reescribir `getLevelFromXP(xp, tier)` con búsqueda binaria (max 7 iteraciones)
  - Agregar helper `intSqrt(n)` (raíz cuadrada entera, Newton's method)
  - Ajustar `getCatchXP()` y `getBuddyBonusXP()` si es necesario

### Impacto en memoria
- **RAM**: 0 extra (reemplaza funciones existentes)
- **Storage**: 0 extra (XP ya está almacenado, solo cambia la interpretación)
- **Migración**: Los Pokémon que ya subieron de nivel podrían "bajar". Aceptable.

---

## FASE 2: Sistema de equipo (Team de 6)

### Concepto
Equipo de 6 Pokémon cuyo **nivel promedio** determina el poder en batallas.
Motiva a subir varios Pokémon, no solo el buddy. Obliga a rotar buddy.

### Nuevo estado en GameState
```
static var team as Lang.Array = [];  // max 6 pokemon ids
```

### Reglas
- El buddy es automáticamente el slot 1 del equipo (gana XP al caminar)
- Los otros 5 se eligen desde la Pokédex (solo Pokémon capturados)
- Se pueden cambiar en cualquier momento
- El **nivel promedio del equipo** se usa en la fórmula de batallas
- Si el equipo tiene menos de 6, el promedio se calcula con los que haya

### Cálculo de nivel promedio
```
sum = 0
for each id in team:
    sum += getLevelFromXP(pokemonXP[id], tier)
avg = sum / team.size()
```

### Por qué 6 y no solo buddy
| Escenario | Resultado |
|-----------|-----------|
| Solo buddy Lv.50, sin equipo | Promedio = 50. Puede ganarle todo fácil |
| Buddy Lv.50 + 5 Pokémon Lv.10 | Promedio = 16. Le cuesta mucho |
| 6 Pokémon todos Lv.30 | Promedio = 30. Equilibrado |

El equipo te obliga a subir **varios** Pokémon, rotando el buddy semana a semana.
Cada captura, cada evolución, y cada caminata importan más.

### Storage extra
1 array de hasta 6 numbers = ~50 bytes. Trivial.

### UI
Desde PokedexView, al tocar un Pokémon capturado:
- "Hacer buddy" (ya existe)
- "Agregar al equipo" (nuevo)
- Ya hay tap detection en `PokedexView.getIdAtTapY()`

### Archivos a modificar
- `source/GameState.mc`: Agregar `team` array, `addToTeam()`, `removeFromTeam()`,
  `getTeamAvgLevel()`, save/load
- `source/PokedexView.mc`: Agregar opción "Agregar al equipo" en tap

---

## FASE 3: Batallas (Pasos vs Tiempo)

### Mecánica central

Las batallas son una **carrera**:
- **HP del rival** → baja con tus **pasos**
- **Tu HP** → baja con el **tiempo**
- Si el rival llega a 0 HP antes → **ganas**
- Si tu HP llega a 0 antes → **pierdes**

Es la misma mecánica de captura salvaje que ya existe, pero con un reloj en contra.

### Fórmula de pasos necesarios

```
pasosNecesarios = pasosBase × nivelRival / nivelPromedioEquipo
```

Una multiplicación y una división. El nivel promedio del equipo determina todo.

### Entrenadores (aparecen en spawns)

El 15% de los spawns son entrenadores en vez de Pokémon salvajes.
Solo 2 tipos de entrenador:

| Clase | Pokémon | Nivel rival | Pasos base | Tiempo | XP |
|-------|---------|-------------|-----------|--------|-----|
| Trainer | 1 aleatorio | avg ± 3 | 600 | 45 min | 200 |
| Ace Trainer | 1 aleatorio | avg + 2 a +6 | 800 | 45 min | 500 |

Variación ±15% en pasos (como ya hacen con HP de salvajes).

**Ejemplos con Trainer (600 base, rival = tu nivel):**
| Tu promedio | Pasos necesarios | Ritmo en 45 min |
|-------------|-----------------|-----------------|
| Lv.10 | 600 | 13/min (paseo) |
| Lv.25 | 600 | 13/min (paseo) |
| Lv.50 | 600 | 13/min (paseo) |

Los trainers siempre son fáciles — sirven para ganar XP y victorias
que desbloquean gimnasios. La dificultad real está en los gyms.

### Spawns durante batallas siguen contando

Cambio clave: `currentBattle` es un slot separado de `currentEncounter`.
El `shouldSpawn()` solo chequea `currentEncounter`, NO `currentBattle`.

Mientras peleas → pasos suman hacia el próximo Pokémon salvaje.
Cuando ganas/pierdes y vuelves → puede haber un Pokémon esperándote.

**Siempre hay algo pasando. Nunca pierdes pasos.**

### Flujo de batalla

**Fase 0 — Aparece el entrenador:**
```
┌──────────────────────────────┐
│                              │
│   [Sprite Pokémon rival]     │  ← sprite existente
│   STARYU Lv.15               │
│                              │
│   ⚔ TRAINER quiere pelear!   │
│                              │
│   Tap → Pelear               │
│   Swipe ← → Huir             │
└──────────────────────────────┘
```
Sin sprites de entrenadores. Se muestra el Pokémon del rival con su sprite existente.

**Fase 1 — Batalla activa (camina para ganar):**
```
┌──────────────────────────────┐
│   ⚔ TRAINER                  │
│                              │
│   [Sprite Pokémon rival]     │
│   STARYU Lv.15               │
│   ██████░░░░  312/600 pasos  │  ← baja con TUS PASOS
│                              │
│   Tu equipo  Avg Lv.20       │
│   ████████░░  32:10 restante │  ← baja con el TIEMPO
│                              │
│   ¡Sigue caminando!          │
└──────────────────────────────┘
```

La pantalla se actualiza cada 1.5s (mismo timer que EncounterView).
El cálculo es:
```
stepsWalked = getCumulativeSteps() - battleStartSteps
timeElapsed = Time.now().value() - battleStartTime

rivalHpPct = 100 - (stepsWalked * 100 / requiredSteps)
yourHpPct  = 100 - (timeElapsed * 100 / timeLimitSec)

if (rivalHpPct <= 0) → victoria
if (yourHpPct <= 0)  → derrota
```

**Fase 2 — Resultado:**
```
┌──────────────────────────────┐
│                              │
│       ¡VICTORIA!             │
│   +200 XP para tu equipo     │
│   Victorias: 5               │
│                              │
│   Tap → continuar            │
└──────────────────────────────┘
```

### Persistencia: funciona aunque cierres el app

El estado de batalla se guarda en Storage (~6 números):
```
battleStartTime      → Time.now().value()
battleStartSteps     → getCumulativeSteps()
battleRequiredSteps  → calculado
battleTimeLimitSec   → ej. 2700 (45 min)
battleRivalId        → id del Pokémon rival
battleRivalLevel     → nivel del rival
battleType           → 0=trainer, 1-20=gym index
```

Al reabrir el app:
1. Leer tiempo transcurrido y pasos caminados
2. Si pasos >= requeridos Y tiempo <= límite → **ganaste**
3. Si tiempo > límite → **perdiste**

No necesitas tener la app abierta. Sales a caminar y cuando vuelves a mirar
el reloj te dice si ganaste o no.

### Archivos nuevos
- **`source/BattleView.mc`** (~200 líneas): Vista + delegate + toda la lógica de batalla

### Archivos a modificar
- `source/SpawnEngine.mc`: Roll 85/15 para tipo de spawn
- `source/MainView.mc`: Detectar batalla activa → pushView(BattleView)
- `source/GameState.mc`: `currentBattle` dict, `rivalWins`, save/load

### Impacto en memoria
- **RAM**: ~1 KB on-demand (solo el dict de batalla + sprite del Pokémon rival)
- **Storage**: ~100 bytes (estado de batalla + rivalWins)
- **PRG**: ~0 bytes extra (0 sprites nuevos)

---

## FASE 4: Gimnasios — 20 batallas (8 Kanto + 8 Johto + 4 Elite Four)

### Concepto
El jugador elige cuándo retar cada gimnasio desde un menú.
Misma mecánica de batalla (pasos vs tiempo), pero mucho más exigente.
Desbloqueo secuencial: Kanto → Johto → Elite Four.

### Fórmula (misma que trainers)
```
pasosNecesarios = pasosBase × nivelRival / nivelPromedioEquipo
```

### Kanto (medallas 1-8) — Desbloqueo por victorias contra trainers

| # | Líder | Pokémon | Lv | Pasos base | Tiempo | Desbloqueo | XP |
|---|-------|---------|-----|-----------|--------|------------|-----|
| 1 | Brock | Onix (#95) | 14 | 2,000 | 45 min | 3 victorias | 500 |
| 2 | Misty | Starmie (#121) | 21 | 2,500 | 50 min | Medalla 1 | 800 |
| 3 | Lt. Surge | Raichu (#26) | 28 | 3,000 | 55 min | Medalla 2 | 1,200 |
| 4 | Erika | Vileplume (#45) | 32 | 3,500 | 60 min | Medalla 3 | 1,800 |
| 5 | Koga | Muk (#89) | 37 | 4,000 | 60 min | Medalla 4 | 2,500 |
| 6 | Sabrina | Alakazam (#65) | 43 | 5,000 | 70 min | Medalla 5 | 3,500 |
| 7 | Blaine | Arcanine (#59) | 47 | 5,500 | 75 min | Medalla 6 | 5,000 |
| 8 | Giovanni | Nidoking (#34) | 50 | 6,000 | 80 min | Medalla 7 | 8,000 |

### Johto (medallas 9-16) — Desbloqueo: 8 medallas de Kanto + secuencial

Empieza donde Kanto terminó (Lv.50) y sube hasta Lv.75.
Los pasos base suben, los tiempos se mantienen o bajan. Más presión.

| # | Líder | Pokémon | Lv | Pasos base | Tiempo | Desbloqueo | XP |
|---|-------|---------|-----|-----------|--------|------------|-----|
| 9 | Falkner | Noctowl (#164) | 52 | 6,500 | 75 min | Medalla 8 | 3,000 |
| 10 | Bugsy | Scyther (#123) | 55 | 7,000 | 75 min | Medalla 9 | 3,500 |
| 11 | Whitney | Miltank (#241) | 58 | 7,500 | 75 min | Medalla 10 | 4,000 |
| 12 | Morty | Gengar (#94) | 62 | 8,000 | 80 min | Medalla 11 | 5,000 |
| 13 | Chuck | Poliwrath (#62) | 65 | 8,500 | 80 min | Medalla 12 | 6,000 |
| 14 | Jasmine | Steelix (#208) | 68 | 9,000 | 80 min | Medalla 13 | 7,000 |
| 15 | Pryce | Piloswine (#221) | 72 | 10,000 | 85 min | Medalla 14 | 9,000 |
| 16 | Clair | Kingdra (#230) | 75 | 11,000 | 90 min | Medalla 15 | 12,000 |

### Elite Four + Champion (17-20) — Desbloqueo: 16 medallas + secuencial

Salto grande de dificultad. Niveles altísimos, muchos pasos, tiempos ajustados.

| # | Trainer | Pokémon | Lv | Pasos base | Tiempo | Desbloqueo | XP |
|---|---------|---------|-----|-----------|--------|------------|-----|
| 17 | Will | Xatu (#178) | 80 | 12,000 | 90 min | Medalla 16 | 10,000 |
| 18 | Koga E4 | Crobat (#169) | 85 | 13,000 | 90 min | Medalla 17 | 12,000 |
| 19 | Bruno | Machamp (#68) | 90 | 14,000 | 100 min | Medalla 18 | 15,000 |
| 20 | Lance | Dragonite (#149) | 95 | 16,000 | 120 min | Medalla 19 | 20,000 |

### Rampa de dificultad (con equipo del nivel justo)

| Zona | Ritmo requerido | Equivale a |
|------|----------------|------------|
| Kanto temprano (1-4) | 40-60 pasos/min | Paseo tranquilo |
| Kanto tardío (5-8) | 65-80 pasos/min | Caminata intensa |
| Johto temprano (9-12) | 85-100 pasos/min | Trote suave |
| Johto tardío (13-16) | 105-125 pasos/min | Corriendo |
| Elite Four (17-20) | 130-145 pasos/min | Carrera sostenida |

Si tu equipo tiene **menos nivel** que el recomendado, los pasos suben
proporcionalmente y se vuelve mucho más difícil o imposible.

### Ejemplos reales

**Brock (Lv.14, 2000 base, 45 min):**
| Equipo avg | Pasos | Ritmo | Dificultad |
|------------|-------|-------|------------|
| Lv.14 | 2,000 | 44/min | Paseo |
| Lv.10 | 2,800 | 62/min | Caminata rápida |
| Lv.25 | 1,120 | 25/min | Trivial |

**Clair (Lv.75, 11000 base, 90 min):**
| Equipo avg | Pasos | Ritmo | Dificultad |
|------------|-------|-------|------------|
| Lv.75 | 11,000 | 122/min | Corriendo |
| Lv.60 | 13,750 | 153/min | Sprint. Casi imposible |
| Lv.90 | 9,167 | 102/min | Trote |

**Lance (Lv.95, 16000 base, 120 min):**
| Equipo avg | Pasos | Ritmo | Dificultad |
|------------|-------|-------|------------|
| Lv.95 | 16,000 | 133/min | Carrera sostenida |
| Lv.75 | 20,267 | 169/min | Imposible |
| Lv.100 | 15,200 | 127/min | Carrera ligera |

**Lance es literalmente un medio maratón si no tienes el nivel suficiente.**

### Flujo de desbloqueo

```
KANTO (3 victorias → luego secuencial)
  Brock → Misty → Surge → Erika → Koga → Sabrina → Blaine → Giovanni
                                                                  │
JOHTO (8 medallas Kanto → secuencial)                             │
  ←───────────────────────────────────────────────────────────────┘
  Falkner → Bugsy → Whitney → Morty → Chuck → Jasmine → Pryce → Clair
                                                                  │
ELITE FOUR (16 medallas → secuencial)                             │
  ←───────────────────────────────────────────────────────────────┘
  Will → Koga E4 → Bruno → Lance = ★ CHAMPION ★
```

### Estados de cada gimnasio
- 🔒 **Bloqueado** (no cumple prerequisito)
- ⚔ **Disponible** (cumple prerequisito, no ganado)
- 🏅 **Ganado** (medalla permanente)

### Medallas en MainView (3 filas de dots)
```
  K: ●●●●●○○○   (8 dots — coloreados si ganados)
  J: ○○○○○○○○   (8 dots — grises hasta desbloquear)
  E: ○○○○        (4 dots)
```

Al completar todo:
```
  K: ●●●●●●●●
  J: ●●●●●●●●
  E: ●●●●  ★ CHAMPION
```

### Datos inline (~20 líneas de código, ~500 bytes)
```
// [nombre, pokemonId, nivel, pasosBase, tiempoSeg, desbloqueo, xpReward]
// desbloqueo: positivo = victorias requeridas, negativo = -# medalla anterior
GYM_DATA = [
  ["Brock",    95, 14, 2000, 2700,   3,   500],
  ["Misty",   121, 21, 2500, 3000,  -1,   800],
  ["Surge",    26, 28, 3000, 3300,  -2,  1200],
  ["Erika",    45, 32, 3500, 3600,  -3,  1800],
  ["Koga",     89, 37, 4000, 3600,  -4,  2500],
  ["Sabrina",  65, 43, 5000, 4200,  -5,  3500],
  ["Blaine",   59, 47, 5500, 4500,  -6,  5000],
  ["Giovanni", 34, 50, 6000, 4800,  -7,  8000],
  ["Falkner", 164, 52, 6500, 4500,  -8,  3000],
  ["Bugsy",   123, 55, 7000, 4500,  -9,  3500],
  ["Whitney", 241, 58, 7500, 4500, -10,  4000],
  ["Morty",    94, 62, 8000, 4800, -11,  5000],
  ["Chuck",    62, 65, 8500, 4800, -12,  6000],
  ["Jasmine", 208, 68, 9000, 4800, -13,  7000],
  ["Pryce",   221, 72,10000, 5100, -14,  9000],
  ["Clair",   230, 75,11000, 5400, -15, 12000],
  ["Will",    178, 80,12000, 5400, -16, 10000],
  ["Koga E4", 169, 85,13000, 5400, -17, 12000],
  ["Bruno",    68, 90,14000, 6000, -18, 15000],
  ["Lance",   149, 95,16000, 7200, -19, 20000],
]
```

### Archivos a modificar
- `source/GameState.mc`: Agregar `gymBadges` (1 número, bitmask de 20 bits), save/load
- `source/MainView.mc`: Mostrar 3 filas de dots + navegación a lista de gyms
- Los datos de gym van inline en `BattleView.mc` o `BalanceConfig.mc`

### Impacto en memoria
- **RAM**: ~500 bytes (tabla estática + estado)
- **Storage**: ~50 bytes (gymBadges + último gym intentado)

---

## Ritmo de juego esperado (día típico ~8,000 pasos)

| Pasos | Evento |
|-------|--------|
| 0-500 | Caminando, buddy gana XP |
| 500 | Spawn → Pidgey salvaje, tap → entras a capturar |
| 900 | Pidgey capturado, vuelves a MainView |
| 1000 | Spawn → ⚔ TRAINER aparece con Sandshrew Lv.12 |
| 1000 | Tap → batalla empieza (600 pasos, 45 min) |
| 1000 | Mientras peleas, spawn timer sigue corriendo |
| 1600 | ¡Victoria! +200 XP. Vuelves a MainView |
| 1600 | ¡Nidoran ya estaba esperando! (pasos de batalla contaron) |
| 2100 | Nidoran capturado |
| 2500 | Spawn → Oddish salvaje |
| 3000 | Spawn → ⚔ ACE TRAINER con Arbok Lv.18 |
| 3800 | Victoria. +500 XP. Total: 4 victorias → ¡Brock disponible! |
| 3800 | Decides retar a Brock (2000 pasos, 45 min) |
| 5800 | ¡Victoria contra Brock! Medalla 1 + 500 XP. Misty disponible |
| 6300 | Spawn → Gastly (¡Raro!) |
| ... | |
| 8000 | ~16 spawns: ~13 salvajes + ~2-3 trainers |

### Progresión a largo plazo

| Semana | Logros estimados |
|--------|-----------------|
| 1 | Equipo Lv.10-15, ~5 victorias, Brock ganado |
| 2 | Equipo Lv.18-22, ~12 victorias, Misty ganada |
| 3-4 | Equipo Lv.25-30, Surge + Erika |
| 1-2 meses | Equipo Lv.35-45, Koga → Giovanni. 8 medallas Kanto |
| 2-3 meses | Johto: Falkner → Morty. Equipo Lv.50-60 |
| 3-5 meses | Johto: Chuck → Clair. Equipo Lv.60-75 |
| 5-8 meses | Elite Four: Will → Bruno. Equipo Lv.75-90 |
| 8-12 meses | Lance derrotado. ★ CHAMPION ★. Equipo Lv.90-100 |

**~1 año de motivación para hacer ejercicio.**
En paralelo: completar Pokédex de 251, conseguir legendarios, shinies.

---

## Resumen de impacto técnico total

| Recurso | Uso adicional | % del límite |
|---------|--------------|-------------|
| RAM (heap) | ~2 KB | ~1.6% de 124 KB |
| Storage | ~150 bytes | ~0.2-0.5% de 28-64 KB |
| PRG (sprites) | **0 bytes** | 0% (sin sprites nuevos) |
| Archivos .mc nuevos | **1** | BattleView.mc |
| Archivos .mc modificados | 4 | BalanceConfig, GameState, SpawnEngine, MainView |

---

## Orden de implementación

| Prioridad | Fase | Descripción | Dependencias |
|-----------|------|-------------|-------------|
| **1** | Fase 1 | Curva XP exponencial | Ninguna |
| **2** | Fase 2 | Equipo de 6 + UI Pokédex | Fase 1 |
| **3** | Fase 3 | Batallas (trainers + vista) | Fase 2 |
| **4** | Fase 4 | 20 Gimnasios + medallas en MainView | Fase 3 |

Cada fase compila y funciona independientemente. Se puede testear y ajustar
antes de avanzar a la siguiente.

---

## Notas de diseño

### ¿Por qué pasos vs tiempo y no turnos?
- El reloj es para caminar, no para jugar con menús
- La mecánica es idéntica a la captura existente (caminar = progreso)
- Input mínimo: tap para aceptar pelea, swipe para huir
- Funciona aunque cierres el app (pasos + tiempo se calculan al reabrir)

### ¿Por qué equipo de 6 y no solo buddy?
- Solo buddy: "subo 1 Pokémon y listo". Juego se acaba rápido
- Equipo de 6: obliga a rotar buddy, subir varios, elegir con estrategia
- Cada captura y evolución tiene impacto real en tu poder de batalla
- Un Charizard Lv.80 con equipo promedio Lv.20 no sirve de nada

### ¿Por qué 20 gyms y no 8?
- Sin sprites nuevos, cada gym cuesta ~25 bytes de datos. Trivial
- 8 gyms se completan en ~2 meses. Demasiado rápido
- 20 gyms con dificultad progresiva = ~1 año de contenido
- Kanto → Johto → Elite Four sigue la historia de los juegos

### ¿Por qué los pasos durante batallas siguen contando para spawns?
- Sin esto, pelear "cuesta" pasos que podrían usarse para capturar
- Con esto, **nunca pierdes pasos**. Siempre estás progresando
- Al salir de una batalla, puede haber un Pokémon esperándote
- Sensación: siempre está pasando algo

### ¿Por qué trainers reemplazan spawns en vez de ser extra?
- Con rivales extra = demasiadas interrupciones
- Reemplazar mantiene el ritmo existente (~16 spawns/día)
- 85% salvajes + 15% trainers = ~2-3 batallas por día

### ¿Por qué no persistir batallas al cerrar el app?
- El estado se guarda (startTime + startSteps + required + timeLimit)
- Al reabrir se recalcula quién gana: si caminaste lo suficiente, ganaste
- Si el tiempo expiró antes, perdiste. Sin penalización
- **Sí funciona en background**: no necesitas tener la app abierta
