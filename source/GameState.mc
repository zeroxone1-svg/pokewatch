// ============================================================
//  GameState.mc — Estado global del juego, guardado y cargado
//  desde el almacenamiento persistente del reloj.
// ============================================================
import Toybox.Application.Storage;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;

class GameState {

    // ── Estado en memoria ─────────────────────────────────
    static var caughtCounts    as Lang.Dictionary = {};  // {id => total_capturadas}
    static var pokedexSeen     as Lang.Array      = [];  // ids vistos
    static var shinyList       as Lang.Array      = [];  // ids shiny atrapados
    static var stepsAtLastSpawn as Lang.Number    = 0;
    static var stepsAtLastBlock as Lang.Number    = 0;
    static var currentEncounter as Lang.Dictionary? = null; // Pokemon activo en encuentro
    static var dailyStreak     as Lang.Number     = 0;
    static var activityBlocksToday as Lang.Number = 0;
    static var lastPlayDate    as Lang.String     = "";
    static var pokemonOfDay    as Lang.Number     = 1;   // id del poke del dia
    static var buddyId         as Lang.Number     = 0;   // 0 = sin buddy
    static var buddySteps      as Lang.Number     = 0;   // pasos acumulados con el buddy
    static var buddyLastSteps  as Lang.Number     = 0;   // referencia de pasos al setear buddy
    static var pokemonXP       as Lang.Dictionary   = {};  // {id_string => total_xp}
    static var totalStepsAllTime as Lang.Number     = 0;   // pasos acumulados de por vida
    static var totalStepsLastRef as Lang.Number     = 0;   // referencia para tracking
    static var legendaryStatus as Lang.Dictionary   = {};  // {id_str => 0:locked/1:ready/2:caught}

    // ── Guardar ───────────────────────────────────────────
    static function save() as Void {
        Storage.setValue("caught",    caughtCounts);
        Storage.setValue("seen",      pokedexSeen);
        Storage.setValue("shinies",   shinyList);
        Storage.setValue("lastSpawn", stepsAtLastSpawn);
        Storage.setValue("lastBlockSteps", stepsAtLastBlock);
        Storage.setValue("blocksToday", activityBlocksToday);
        Storage.setValue("streak",    dailyStreak);
        Storage.setValue("lastDate",  lastPlayDate);
        Storage.setValue("podDay",    pokemonOfDay);        Storage.setValue("buddyId",   buddyId);
        Storage.setValue("buddySteps", buddySteps);
        Storage.setValue("buddyLastSteps", buddyLastSteps);
        Storage.setValue("pokemonXP", pokemonXP);
        Storage.setValue("totalSteps", totalStepsAllTime);
        Storage.setValue("totalStepsRef", totalStepsLastRef);
        Storage.setValue("legendaryStatus", legendaryStatus);
        // Persistir encuentro activo (convertir Symbol keys a String keys)
        if (currentEncounter != null) {
            var encStore = {
                "id"      => currentEncounter[:id],
                "isShiny" => currentEncounter[:isShiny],
                "hpMax"   => currentEncounter[:hpMax],
                "hpCurr"  => currentEncounter[:hpCurr],
                "stepPowerPercent" => currentEncounter[:stepPowerPercent],
                "stepsAtStart" => currentEncounter[:stepsAtStart]
            };
            Storage.setValue("encounter", encStore);
        } else {
            Storage.deleteValue("encounter");
        }
    }

    // ── Cargar ────────────────────────────────────────────
    static function load() as Void {
        var c = Storage.getValue("caught");
        caughtCounts    = (c != null) ? c : {};

        var s = Storage.getValue("seen");
        pokedexSeen     = (s != null) ? s : [];

        var sh = Storage.getValue("shinies");
        shinyList       = (sh != null) ? sh : [];

        var ls = Storage.getValue("lastSpawn");
        stepsAtLastSpawn = (ls != null) ? ls : 0;

        var lbs = Storage.getValue("lastBlockSteps");
        stepsAtLastBlock = (lbs != null) ? lbs : 0;

        var bt = Storage.getValue("blocksToday");
        activityBlocksToday = (bt != null) ? bt : 0;

        var st = Storage.getValue("streak");
        dailyStreak     = (st != null) ? st : 0;

        var ld = Storage.getValue("lastDate");
        lastPlayDate    = (ld != null) ? ld : "";

        var pod = Storage.getValue("podDay");
        pokemonOfDay    = (pod != null) ? pod : 1;

        var bi = Storage.getValue("buddyId");
        buddyId = (bi != null) ? bi : 0;

        var bs = Storage.getValue("buddySteps");
        buddySteps = (bs != null) ? bs : 0;

        var bls = Storage.getValue("buddyLastSteps");
        buddyLastSteps = (bls != null) ? bls : 0;

        var pxp = Storage.getValue("pokemonXP");
        pokemonXP = (pxp != null) ? pxp : {};

        var ts = Storage.getValue("totalSteps");
        totalStepsAllTime = (ts != null) ? ts : 0;
        var tsr = Storage.getValue("totalStepsRef");
        totalStepsLastRef = (tsr != null) ? tsr : 0;
        var lstat = Storage.getValue("legendaryStatus");
        legendaryStatus = (lstat != null) ? lstat : {};

        // Restaurar encuentro activo (convertir String keys de vuelta a Symbol keys)
        var enc = Storage.getValue("encounter");
        if (enc != null) {
            var encDict = enc as Lang.Dictionary;
            currentEncounter = {
                :id      => encDict["id"],
                :isShiny => encDict["isShiny"],
                :hpMax   => encDict["hpMax"],
                :hpCurr  => encDict["hpCurr"],
                :stepPowerPercent => encDict["stepPowerPercent"],
                :stepsAtStart => encDict["stepsAtStart"]
            };
        } else {
            currentEncounter = null;
        }

        // Revisar si es un nuevo día
        checkNewDay();
    }

    // ── Pasos actuales del reloj ──────────────────────────
    static function getStepsToday() as Lang.Number {
        var info = ActivityMonitor.getInfo();
        if (info != null && info.steps != null) {
            return info.steps;
        }
        return 0;
    }

    // ── ¿Es momento de generar un encuentro? ─────────────
    static function shouldSpawn() as Lang.Boolean {
        checkNewDay();
        if (currentEncounter != null) { return false; }
        var steps = getStepsToday();
        // Si el contador de pasos bajó (reset del reloj), ajustar
        if (steps < stepsAtLastSpawn) {
            stepsAtLastSpawn = steps;
            save();
        }
        return (steps - stepsAtLastSpawn) >= BalanceConfig.getStepsPerSpawn();
    }

    // ── Registrar que se generó un spawn ─────────────────
    static function markSpawn() as Void {
        stepsAtLastSpawn = getStepsToday();
        save();
    }

    // ── Pasos para el próximo encuentro ──────────────────
    static function stepsUntilNext() as Lang.Number {
        checkNewDay();
        var steps = getStepsToday();
        // Si el contador bajó, resetear referencia
        if (steps < stepsAtLastSpawn) {
            stepsAtLastSpawn = steps;
            save();
        }
        var diff = steps - stepsAtLastSpawn;
        var spawnInterval = BalanceConfig.getStepsPerSpawn();
        var remaining = spawnInterval - diff;
        if (remaining < 0) { remaining = 0; }
        if (remaining > spawnInterval) { remaining = spawnInterval; }
        return remaining;
    }

    // ── Nuevo día ─────────────────────────────────────────
    static function checkNewDay() as Void {
        var today = getDateString();
        if (lastPlayDate.equals("")) {
            lastPlayDate = today;
            var stepsInit = getStepsToday();
            stepsAtLastSpawn = stepsInit;
            stepsAtLastBlock = stepsInit;
            save();
            return;
        }

        if (!today.equals(lastPlayDate)) {
            if (activityBlocksToday > 0) {
                dailyStreak += 1;
            } else {
                dailyStreak = 0;
            }

            var stepsNow = getStepsToday();
            stepsAtLastSpawn = stepsNow;
            stepsAtLastBlock = stepsNow;
            activityBlocksToday = 0;
            pokemonOfDay = (Math.rand() % 151) + 1;
            lastPlayDate = today;
            save();
        }
    }

    static function getDateString() as Lang.String {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        return info.year.toString() + "-" + info.month.toString() + "-" + info.day.toString();
    }

    static function updateActivityBlocks() as Void {
        checkNewDay();

        var stepsNow = getStepsToday();
        if (stepsNow < stepsAtLastBlock) {
            stepsAtLastBlock = stepsNow;
        }

        var changed = false;
        while ((stepsNow - stepsAtLastBlock) >= BalanceConfig.getStepsPerActivityBlock()) {
            activityBlocksToday += 1;
            stepsAtLastBlock += BalanceConfig.getStepsPerActivityBlock();
            changed = true;
        }

        if (changed) {
            save();
        }
    }

    static function getActivityBlocksToday() as Lang.Number {
        updateActivityBlocks();
        return activityBlocksToday;
    }

    static function stepsUntilNextActivityBlock() as Lang.Number {
        updateActivityBlocks();
        var remaining = BalanceConfig.getStepsPerActivityBlock() - (getStepsToday() - stepsAtLastBlock);
        return (remaining > 0) ? remaining : 0;
    }

    // ── Total de Pokémon distintos atrapados ──────────────
    static function uniqueCaught() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= 151; i++) {
            var key = i.toString();
            if (caughtCounts.hasKey(key) && caughtCounts[key] > 0) {
                count++;
            }
        }
        return count;
    }

    // ── Cuántos de un id se han atrapado ──────────────────
    static function getCaughtCount(id as Lang.Number) as Lang.Number {
        var key = id.toString();
        if (caughtCounts.hasKey(key)) {
            return caughtCounts[key];
        }
        return 0;
    }

    // ── Registrar captura ─────────────────────────────────
    static function registerCatch(id as Lang.Number, isShiny as Lang.Boolean) as Void {
        var key = id.toString();
        var prev = getCaughtCount(id);
        caughtCounts[key] = prev + 1;

        registerSeen(id);

        // Shiny
        if (isShiny && shinyList.indexOf(id) == -1) {
            shinyList.add(id);
        }

        // XP por captura (siempre va al Pokémon capturado)
        var data = PokemonData.get(id);
        var tier = data[:tier];
        var catchXP = BalanceConfig.getCatchXP(tier);
        addPokemonXP(id, catchXP);

        // Bonus XP al buddy SOLO si es de la misma línea evolutiva
        if (buddyId > 0 && isSameEvolutionLine(id, buddyId)) {
            var bonusXP = BalanceConfig.getBuddyBonusXP(tier);
            addPokemonXP(buddyId, bonusXP);
        }

        // Marcar legendario por misión como atrapado
        if (id == 144 || id == 145 || id == 146 || id == 150 || id == 151) {
            legendaryStatus[id.toString()] = 2;
        }

        save();
    }

    static function registerSeen(id as Lang.Number) as Void {
        if (pokedexSeen.indexOf(id) == -1) {
            pokedexSeen.add(id);
            save();
        }
    }

    // ── Medalla actual ────────────────────────────────────
    static function getMedal() as Lang.String {
        var u = uniqueCaught();
        if (u >= 100) { return "ORO"; }
        if (u >= 50)  { return "PLATA"; }
        if (u >= 10)  { return "BRONCE"; }
        return "";
    }
    // ── Buddy System ─────────────────────────────────────
    static function setBuddy(id as Lang.Number) as Void {
        buddyId = id;
        buddySteps = 0;
        buddyLastSteps = getStepsToday();
        save();
    }

    // Actualizar pasos del buddy (cada paso = 1 XP para el buddy)
    static function updateBuddySteps() as Void {
        if (buddyId == 0) { return; }
        var stepsNow = getStepsToday();
        if (stepsNow < buddyLastSteps) {
            buddyLastSteps = stepsNow; // reset del reloj
        }
        var newSteps = stepsNow - buddyLastSteps;
        if (newSteps > 0) {
            buddySteps += newSteps;
            buddyLastSteps = stepsNow;
            addPokemonXP(buddyId, newSteps);
        }
    }

    // ── Total Steps (para misiones legendarias) ───────────
    static function updateTotalSteps() as Void {
        var stepsNow = getStepsToday();
        if (stepsNow < totalStepsLastRef) {
            totalStepsLastRef = 0;
        }
        var delta = stepsNow - totalStepsLastRef;
        if (delta > 0) {
            totalStepsAllTime += delta;
            totalStepsLastRef = stepsNow;
        }
    }

    static function getLegendaryStatus(id as Lang.Number) as Lang.Number {
        var key = id.toString();
        if (legendaryStatus.hasKey(key)) {
            return legendaryStatus[key];
        }
        return 0;
    }

    static function setLegendaryStatus(id as Lang.Number, st as Lang.Number) as Void {
        legendaryStatus[id.toString()] = st;
        save();
    }

    // ── XP / Nivel por Pokémon ────────────────────────────
    static function getPokemonXP(id as Lang.Number) as Lang.Number {
        var key = id.toString();
        if (pokemonXP.hasKey(key)) {
            return pokemonXP[key];
        }
        return 0;
    }

    static function addPokemonXP(id as Lang.Number, amount as Lang.Number) as Void {
        var key = id.toString();
        var current = getPokemonXP(id);
        pokemonXP[key] = current + amount;
    }

    static function getPokemonLevel(id as Lang.Number) as Lang.Number {
        return BalanceConfig.getLevelFromXP(getPokemonXP(id));
    }

    // ── Familia evolutiva ─────────────────────────────────
    // Verifica si caughtId está en la misma línea evolutiva que buddyId.
    // Sigue la cadena evoTo desde caughtId hasta 3 niveles de profundidad.
    static function isSameEvolutionLine(caughtId as Lang.Number, targetId as Lang.Number) as Lang.Boolean {
        if (caughtId == targetId) { return true; }
        // Seguir cadena evolutiva del capturado
        var id = caughtId;
        for (var depth = 0; depth < 3; depth++) {
            var d = PokemonData.get(id);
            var evoTo = d[:evoTo];
            if (evoTo <= 0) { break; }
            if (evoTo == targetId) { return true; }
            id = evoTo;
        }
        // Eevee (133) → Vaporeon(134)/Jolteon(135)/Flareon(136)
        if (caughtId == 133 && (targetId == 134 || targetId == 135 || targetId == 136)) {
            return true;
        }
        // Eeveeluciones → Eevee
        if (targetId == 133 && (caughtId == 134 || caughtId == 135 || caughtId == 136)) {
            return true;
        }
        return false;
    }

    // Nivel requerido para que el buddy evolucione
    static function getBuddyEvoLevel() as Lang.Number {
        if (buddyId == 0) { return 0; }
        var data = PokemonData.get(buddyId);
        var baseCost = data[:evoCost];
        return BalanceConfig.getEvolutionLevel(baseCost);
    }

    // Verificar si el buddy puede evolucionar (basado en nivel)
    static function checkBuddyEvolution() as Lang.Number {
        if (buddyId == 0) { return 0; }
        var data = PokemonData.get(buddyId);
        var evoTo = data[:evoTo];
        if (evoTo == 0) { return 0; } // no evoluciona
        var requiredLevel = getBuddyEvoLevel();
        if (requiredLevel <= 0) { return 0; }
        var currentLevel = getPokemonLevel(buddyId);
        if (currentLevel >= requiredLevel) {
            // Eevee: evolución aleatoria
            if (evoTo == -1) {
                var opts = [134, 135, 136];
                evoTo = opts[Math.rand() % 3];
            }
            // Transferir XP al evolucionado
            var currentXP = getPokemonXP(buddyId);
            addPokemonXP(evoTo, currentXP);
            // Registrar la evolución
            registerCatch(evoTo, false);
            registerSeen(evoTo);
            // Actualizar el buddy al evolucionado
            buddyId = evoTo;
            buddySteps = 0;
            save();
            return evoTo;
        }
        return 0;
    }

    // Progreso del buddy como porcentaje (0-100) basado en nivel
    static function getBuddyProgress() as Lang.Number {
        if (buddyId == 0) { return 0; }
        var requiredLevel = getBuddyEvoLevel();
        if (requiredLevel <= 0) { return 100; } // ya es forma final
        var currentLevel = getPokemonLevel(buddyId);
        var pct = (currentLevel * 100) / requiredLevel;
        if (pct > 100) { pct = 100; }
        return pct;
    }}
