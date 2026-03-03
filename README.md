# ⌚ PokéWatch v1 — Guía de instalación completa

## ¿Qué necesitas?
- VS Code (gratuito): https://code.visualstudio.com
- Extensión "Monkey C" de Garmin para VS Code
- Tu Vivoactive 6 conectado por USB o Bluetooth

---

## Paso 1 — Instalar VS Code
Descarga e instala VS Code desde code.visualstudio.com

---

## Paso 2 — Instalar la extensión Monkey C
1. Abre VS Code
2. Clic en el ícono de extensiones (cuadraditos a la izquierda)
3. Busca: **Monkey C**
4. Instala la extensión oficial de Garmin
5. Te pedirá instalar el SDK — acepta todo
6. Reinicia VS Code

---

## Paso 3 — Abrir este proyecto
1. En VS Code: File → Open Folder
2. Selecciona la carpeta `pokewatch`
3. VS Code reconocerá el proyecto automáticamente

---

## Paso 4 — Compilar y probar en simulador
1. Presiona **Ctrl+Shift+P** (o Cmd+Shift+P en Mac)
2. Escribe: `Monkey C: Run Current Project`
3. Selecciona **vivoactive6** como dispositivo
4. Se abrirá el simulador con tu app

---

## Paso 5 — Instalar en tu reloj real
1. Conecta tu Vivoactive 6 por USB
2. Presiona **Ctrl+Shift+P**
3. Escribe: `Monkey C: Export Project`
4. Elige tu reloj de la lista
5. La app aparecerá en el menú de aplicaciones del reloj

---

## Estructura del proyecto
```
pokewatch/
├── manifest.xml              ← Configuración del proyecto
├── source/
│   ├── PokeWatchApp.mc       ← Entrada principal de la app
│   ├── GameState.mc          ← Estado del juego (guardado/cargado)
│   ├── PokemonData.mc        ← Los 151 Pokémon con su data
│   ├── BalanceConfig.mc      ← Ajustes de dificultad y progreso
│   ├── SpawnEngine.mc        ← Lógica de encuentros y daño por pasos
│   ├── EvolutionManager.mc   ← Sistema de evoluciones
│   ├── MainView.mc           ← Pantalla principal
│   ├── EncounterView.mc      ← Pantalla de encuentro con Pokémon
│   └── PokedexView.mc        ← Pokédex y Perfil
└── resources/
    └── strings/strings.xml   ← Textos de la app
```

---

## Cómo se juega

### Mecánica principal
- Cada **200 pasos** hay posibilidad de encontrar un Pokémon
- Cuando aparece, su **HP baja con tus pasos**
- Cuando HP llega a 0 → **captura automática**
- Puedes **dejar ir** al Pokémon si no quieres capturarlo
- Cada **600 pasos activos** completas 1 bloque
- Con **2 bloques en el día** obtienes bonus de aparición para raros/muy raros
- Más bloques también mejoran tu probabilidad de spawn por intento
- Más bloques aumentan tu poder de paso en encuentros (capturas más fluidas)

### Tiers de rareza
| Tier | Aparición | HP (pasos) |
|------|-----------|------------|
| Común | 55% | 400–600 |
| Poco común | 25% | 700–1,000 |
| Raro | 12% | 1,200–1,800 |
| Muy raro | 6% | 2,500–4,000 |
| Legendario | 2% | 8,000–12,000 |

### Shinys
- Probabilidad: **1 en 450** por encuentro
- Se muestran con ★ en el nombre
- Se guardan separados en tu Pokédex

### Evoluciones
- Capturando el mismo Pokémon repetidas veces
- Caterpie x25 → Metapod → Butterfree
- Charmander x50 → Charmeleon x50 → Charizard
- Pikachu x100 → Raichu
- Eevee x100 → Vaporeon / Jolteon / Flareon (aleatorio)
- ¡Magikarp necesita 400 capturas para ser Gyarados! 😂

### Pokémon del día
- Cada día hay 1 Pokémon con **3x más probabilidad** de aparecer
- Lo ves en la pantalla principal

### Racha
- Si completas al menos 1 bloque activo en el día, tu racha sube al cambiar de día

### Medallas
- 🥉 Bronce: 10 Pokémon distintos
- 🥈 Plata: 50 Pokémon distintos
- 🥇 Oro: 100 Pokémon distintos

### Navegación en el reloj
- **Pantalla principal** → pasos, Pokémon del día, próximo encuentro
- **Swipe arriba** → Pokédex
- **Swipe abajo** → Perfil / estadísticas
- **Toca** → ir al encuentro activo

### Ajustar dificultad (un solo archivo)
Toda la dificultad principal se ajusta en `source/BalanceConfig.mc`:
- Frecuencia de encuentros (`getStepsPerSpawn`)
- Probabilidad de aparición por intento (`getSpawnRoll*`)
- Tamaño de bloque activo (`getStepsPerActivityBlock`)
- Bonus por actividad y tiers afectados (`getActivityBonus*`, `isRareBonusTier`)
- Escalado de spawn por bloques (`getSpawnRollSuccessMaxForBlocks`)
- Escalado de daño por bloques (`getStepPowerPercent`)
- Rareza base (`getTierWeights`)
- Probabilidad shiny (`getShinyOdds`)
- Variación de HP (`getHpVariationPercent`)

Presets listos:
- `PRESET_CASUAL`
- `PRESET_MEDIUM`
- `PRESET_CHALLENGING`

Para cambiar dificultad, modifica una sola línea:
- `ACTIVE_PRESET = PRESET_MEDIUM` (por ejemplo a `PRESET_CASUAL`)

---

## ¿Cuánto tiempo para completar los 151?
Con 5,000–7,000 pasos diarios:
- Ver los 151: ~4–6 meses
- Atrapar uno de cada uno: ~6–9 meses
- Completar evoluciones: ~12–18 meses
- Shiny de cada uno: muchos años 😅

---

## Roadmap v2 (futuro)
- Sprites visuales de los Pokémon
- Sistema de clima real del teléfono
- Combates simples contra Pokémon rivales
- Objetos (Pokéballs, Pociones)
- Notificaciones cuando aparece un legendario
