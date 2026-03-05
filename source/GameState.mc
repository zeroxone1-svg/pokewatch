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

    // ── Team & Battle System ──────────────────────────────
    static var team            as Lang.Array      = [];  // max 6 pokemon ids
    static var rivalWins       as Lang.Number     = 0;   // total trainer victories
    static var gymBadges       as Lang.Number     = 0;   // bitmask of 20 bits
    static var currentBattle   as Lang.Dictionary? = null; // active battle state

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
        Storage.setValue("team", team);
        Storage.setValue("rivalWins", rivalWins);
        Storage.setValue("gymBadges", gymBadges);
        // Persistir batalla activa
        if (currentBattle != null) {
            var batStore = {
                "startTime"     => currentBattle[:startTime],
                "startSteps"    => currentBattle[:startSteps],
                "requiredSteps" => currentBattle[:requiredSteps],
                "timeLimitSec"  => currentBattle[:timeLimitSec],
                "rivalId"       => currentBattle[:rivalId],
                "rivalLevel"    => currentBattle[:rivalLevel],
                "battleType"    => currentBattle[:battleType],
                "xpReward"      => currentBattle[:xpReward]
            };
            Storage.setValue("battle", batStore);
        } else {
            Storage.deleteValue("battle");
        }
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
        try { System.println("GameState.load: start"); } catch (e) {}
            var c = null;
            try {
                c = Storage.getValue("caught");
                try { System.println("GameState.load: key 'caught' read: " + (c == null ? "null" : "ok")); } catch (e) {}
            } catch (e) {
                try { System.println("GameState.load: Storage.getValue('caught') threw: " + e.toString()); } catch (e2) {}
                c = null;
            }
        caughtCounts    = (c != null) ? c : {};
        try { System.println("GameState.load: caught loaded"); } catch (e) {}

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

        var tm = Storage.getValue("team");
        team = (tm != null) ? tm : [];
        var rw = Storage.getValue("rivalWins");
        rivalWins = (rw != null) ? rw : 0;
        var gb = Storage.getValue("gymBadges");
        gymBadges = (gb != null) ? gb : 0;

        // Restaurar batalla activa
        var bat = Storage.getValue("battle");
        if (bat != null) {
            var batDict = bat as Lang.Dictionary;
            currentBattle = {
                :startTime     => batDict["startTime"],
                :startSteps    => batDict["startSteps"],
                :requiredSteps => batDict["requiredSteps"],
                :timeLimitSec  => batDict["timeLimitSec"],
                :rivalId       => batDict["rivalId"],
                :rivalLevel    => batDict["rivalLevel"],
                :battleType    => batDict["battleType"],
                :xpReward      => batDict["xpReward"]
            };
        } else {
            currentBattle = null;
        }

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

        // ── Migración v1→v2: de pasos diarios a acumulados ──
        var migrated = Storage.getValue("v2");
        if (migrated == null || migrated != true) {
            updateTotalSteps();
            stepsAtLastSpawn = totalStepsAllTime;
            stepsAtLastBlock = totalStepsAllTime;
            buddyLastSteps   = totalStepsAllTime;
            if (currentEncounter != null) {
                currentEncounter[:stepsAtStart] = totalStepsAllTime;
            }
            Storage.setValue("v2", true);
            save();
        }

        // Revisar si es un nuevo día
        checkNewDay();
    }

    // ── Pasos actuales del reloj (solo para UI) ──────────
    static function getStepsToday() as Lang.Number {
        var info = ActivityMonitor.getInfo();
        if (info != null && info.steps != null) {
            return info.steps;
        }
        return 0;
    }

    // ── Pasos acumulados de por vida (para tracking interno) ──
    // Siempre creciente, nunca se reinicia al cambiar de día.
    static function getCumulativeSteps() as Lang.Number {
        updateTotalSteps();
        return totalStepsAllTime;
    }

    // ── ¿Es momento de generar un encuentro? ─────────────
    static function shouldSpawn() as Lang.Boolean {
        checkNewDay();
        if (currentEncounter != null) { return false; }
        var steps = getCumulativeSteps();
        // Safety: si por alguna razón bajó, ajustar
        if (steps < stepsAtLastSpawn) {
            stepsAtLastSpawn = steps;
            save();
        }
        return (steps - stepsAtLastSpawn) >= BalanceConfig.getStepsPerSpawn();
    }

    // ── Registrar que se generó un spawn ─────────────────
    static function markSpawn() as Void {
        stepsAtLastSpawn = getCumulativeSteps();
        save();
    }

    // ── Pasos para el próximo encuentro ──────────────────
    static function stepsUntilNext() as Lang.Number {
        checkNewDay();
        var steps = getCumulativeSteps();
        // Safety: si por alguna razón bajó, ajustar
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
            var stepsInit = getCumulativeSteps();
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

            // Solo resetear bloques de actividad (son diarios).
            // stepsAtLastSpawn NO se reinicia: el progreso hacia
            // el próximo spawn se mantiene entre días.
            stepsAtLastBlock = getCumulativeSteps();
            activityBlocksToday = 0;
            pokemonOfDay = (Math.rand() % PokemonData.TOTAL_POKEMON) + 1;
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

        var stepsNow = getCumulativeSteps();
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
        var remaining = BalanceConfig.getStepsPerActivityBlock() - (getCumulativeSteps() - stepsAtLastBlock);
        return (remaining > 0) ? remaining : 0;
    }

    // ── Total de Pokémon distintos atrapados ──────────────
    static function uniqueCaught() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= PokemonData.TOTAL_POKEMON; i++) {
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
        registerCatchInternal(id, isShiny, true);
    }

    // ── Registrar evolución (sin XP extra) ────────────────
    static function registerEvolution(id as Lang.Number) as Void {
        registerCatchInternal(id, false, false);
    }

    // ── Lógica compartida de registro ─────────────────────
    static function registerCatchInternal(id as Lang.Number, isShiny as Lang.Boolean, giveXP as Lang.Boolean) as Void {
        var key = id.toString();
        var prev = getCaughtCount(id);
        caughtCounts[key] = prev + 1;

        registerSeen(id);

        // Shiny
        if (isShiny && shinyList.indexOf(id) == -1) {
            shinyList.add(id);
        }

        if (giveXP) {
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
        }

        // Marcar legendario por misión como atrapado
        if (LegendaryQuestManager.isQuestLegendary(id)) {
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
        if (u >= 200) { return "DIAMANTE"; }
        if (u >= 151) { return "ORO"; }
        if (u >= 100) { return "PLATA"; }
        if (u >= 50)  { return "BRONCE"; }
        return "";
    }
    // ── Buddy System ─────────────────────────────────────
    static function setBuddy(id as Lang.Number) as Void {
        buddyId = id;
        buddySteps = 0;
        buddyLastSteps = getCumulativeSteps();
        save();
    }

    // Actualizar pasos del buddy (cada paso = 1 XP para el buddy)
    static function updateBuddySteps() as Void {
        if (buddyId == 0) { return; }
        var stepsNow = getCumulativeSteps();
        if (stepsNow < buddyLastSteps) {
            buddyLastSteps = stepsNow;
        }
        var newSteps = stepsNow - buddyLastSteps;
        if (newSteps > 0) {
            buddySteps += newSteps;
            buddyLastSteps = stepsNow;
            addPokemonXP(buddyId, newSteps);
        }
    }

    // ── Total Steps (acumulado de por vida) ───────────────
    // Usa getStepsToday() internamente para computar deltas
    // contra el contador diario del reloj.
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
        var data = PokemonData.get(id);
        var tier = data[:tier];
        return BalanceConfig.getLevelFromXP(getPokemonXP(id), tier);
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
        // Eevee (133) → Vaporeon(134)/Jolteon(135)/Flareon(136)/Espeon(196)/Umbreon(197)
        var eeveeEvos = [134, 135, 136, 196, 197];
        if (caughtId == 133) {
            for (var e = 0; e < eeveeEvos.size(); e++) {
                if (targetId == eeveeEvos[e]) { return true; }
            }
        }
        if (targetId == 133) {
            for (var e = 0; e < eeveeEvos.size(); e++) {
                if (caughtId == eeveeEvos[e]) { return true; }
            }
        }
        // Branching evos: Gloom, Poliwhirl, Slowpoke, Tyrogue
        var branchFamilies = [
            [44, 45, 182],   // Gloom → Vileplume/Bellossom
            [61, 62, 186],   // Poliwhirl → Poliwrath/Politoed
            [79, 80, 199],   // Slowpoke → Slowbro/Slowking
            [236, 106, 107, 237] // Tyrogue → Hitmonlee/Hitmonchan/Hitmontop
        ];
        for (var f = 0; f < branchFamilies.size(); f++) {
            var fam = branchFamilies[f];
            var inFam = false;
            for (var m = 0; m < fam.size(); m++) {
                if (caughtId == fam[m] || targetId == fam[m]) { inFam = true; break; }
            }
            if (inFam) {
                for (var m = 0; m < fam.size(); m++) {
                    if (caughtId == fam[m] || targetId == fam[m]) { /* check both */ }
                }
                var hasCaught = false;
                var hasTarget = false;
                for (var m = 0; m < fam.size(); m++) {
                    if (caughtId == fam[m]) { hasCaught = true; }
                    if (targetId == fam[m]) { hasTarget = true; }
                }
                if (hasCaught && hasTarget) { return true; }
            }
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
            // Evolución aleatoria para Pokémon con múltiples opciones
            if (evoTo == -1) {
                evoTo = EvolutionManager.pickBranchEvolution(buddyId);
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
    }

    // ── Team System ───────────────────────────────────────
    static function addToTeam(id as Lang.Number) as Lang.Boolean {
        if (team.size() >= 6) { return false; }
        if (team.indexOf(id) != -1) { return false; }
        team.add(id);
        save();
        return true;
    }

    static function removeFromTeam(id as Lang.Number) as Void {
        var idx = team.indexOf(id);
        if (idx != -1) {
            team.remove(id);
            save();
        }
    }

    static function isInTeam(id as Lang.Number) as Lang.Boolean {
        return team.indexOf(id) != -1;
    }

    static function getTeamAvgLevel() as Lang.Number {
        // Buddy siempre cuenta como slot 1
        var ids = [] as Lang.Array;
        if (buddyId > 0) {
            ids.add(buddyId);
        }
        for (var i = 0; i < team.size(); i++) {
            if (team[i] != buddyId && ids.size() < 6) {
                ids.add(team[i]);
            }
        }
        if (ids.size() == 0) { return 1; }
        var sum = 0;
        for (var i = 0; i < ids.size(); i++) {
            sum += getPokemonLevel(ids[i]);
        }
        return sum / ids.size();
    }

    // ── Battle System ─────────────────────────────────────
    static function startBattle(rivalId as Lang.Number, rivalLevel as Lang.Number,
                                requiredSteps as Lang.Number, timeLimitSec as Lang.Number,
                                battleType as Lang.Number, xpReward as Lang.Number) as Void {
        currentBattle = {
            :startTime     => Time.now().value(),
            :startSteps    => getCumulativeSteps(),
            :requiredSteps => requiredSteps,
            :timeLimitSec  => timeLimitSec,
            :rivalId       => rivalId,
            :rivalLevel    => rivalLevel,
            :battleType    => battleType,
            :xpReward      => xpReward
        };
        save();
    }

    static function getBattleStepsWalked() as Lang.Number {
        if (currentBattle == null) { return 0; }
        var walked = getCumulativeSteps() - currentBattle[:startSteps];
        return (walked > 0) ? walked : 0;
    }

    static function getBattleTimeElapsed() as Lang.Number {
        if (currentBattle == null) { return 0; }
        var elapsed = Time.now().value() - currentBattle[:startTime];
        return (elapsed > 0) ? elapsed : 0;
    }

    // Returns: 0=in progress, 1=victory, 2=defeat
    static function checkBattleResult() as Lang.Number {
        if (currentBattle == null) { return 0; }
        var stepsWalked = getBattleStepsWalked();
        var timeElapsed = getBattleTimeElapsed();
        var required = currentBattle[:requiredSteps];
        var timeLimit = currentBattle[:timeLimitSec];
        if (stepsWalked >= required && timeElapsed <= timeLimit) {
            return 1; // victory
        }
        if (timeElapsed > timeLimit) {
            return 2; // defeat
        }
        return 0; // in progress
    }

    static function finishBattle(victory as Lang.Boolean) as Void {
        if (currentBattle == null) { return; }
        if (victory) {
            var xp = currentBattle[:xpReward];
            var bType = currentBattle[:battleType];
            // Distribute XP to team
            distributeTeamXP(xp);
            rivalWins += 1;
            // If gym battle, set badge
            if (bType >= 0 && bType < BalanceConfig.GYM_COUNT) {
                gymBadges = gymBadges | (1 << bType);
            }
        }
        currentBattle = null;
        save();
    }

    static function distributeTeamXP(totalXP as Lang.Number) as Void {
        var ids = [] as Lang.Array;
        if (buddyId > 0) { ids.add(buddyId); }
        for (var i = 0; i < team.size(); i++) {
            if (team[i] != buddyId && ids.size() < 6) {
                ids.add(team[i]);
            }
        }
        if (ids.size() == 0) { return; }
        var each = totalXP / ids.size();
        if (each < 1) { each = 1; }
        for (var i = 0; i < ids.size(); i++) {
            addPokemonXP(ids[i], each);
        }
    }

    // ── Gym System ────────────────────────────────────────
    static function hasGymBadge(gymIndex as Lang.Number) as Lang.Boolean {
        return (gymBadges & (1 << gymIndex)) != 0;
    }

    static function getGymBadgeCount() as Lang.Number {
        var count = 0;
        for (var i = 0; i < BalanceConfig.GYM_COUNT; i++) {
            if (hasGymBadge(i)) { count += 1; }
        }
        return count;
    }

    // 0=locked, 1=available, 2=won
    static function getGymStatus(gymIndex as Lang.Number) as Lang.Number {
        if (hasGymBadge(gymIndex)) { return 2; }
        var gymData = BalanceConfig.GYM_DATA[gymIndex];
        var unlock = gymData[5];
        if (unlock == 0) {
            // No requirement — always available
            return 1;
        } else if (unlock > 0) {
            // Positive: requires N rival wins
            if (rivalWins >= unlock) { return 1; }
            return 0;
        } else {
            // Negative: requires previous badge
            var prevIdx = (-unlock) - 1;
            if (hasGymBadge(prevIdx)) { return 1; }
            return 0;
        }
    }
}
