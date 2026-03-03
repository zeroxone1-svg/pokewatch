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
    static var totalSteps      as Lang.Number     = 0;
    static var pokemonOfDay    as Lang.Number     = 1;   // id del poke del dia

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
        Storage.setValue("podDay",    pokemonOfDay);
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

        currentEncounter = null;

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
}
