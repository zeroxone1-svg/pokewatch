// ============================================================
//  LegendaryQuestManager.mc — Misiones para legendarios.
//
//  Los legendarios NO aparecen por spawn normal.
//  Cada uno requiere cumplir una condición especial.
//
//  ── Gen 1 (Kanto) ──
//  Articuno (144): 500,000 pasos totales acumulados
//  Zapdos   (145): Racha de 30 días activos consecutivos
//  Moltres  (146): 500 capturas totales individuales
//  Mewtwo   (150): Todos los Pokémon normales de Kanto
//  Mew      (151): Capturar Articuno + Zapdos + Moltres
//
//  ── Gen 2 (Johto) ──
//  Raikou   (243): 10,000 pasos en un día (req. 50K totales)
//  Entei    (244): 1,000,000 pasos totales acumulados
//  Suicune  (245): Racha de 60 días activos consecutivos
//  Lugia    (249): Capturar las 3 bestias (Raikou+Entei+Suicune)
//  Ho-Oh    (250): Completar Pokédex de Kanto (151 especies)
//  Celebi   (251): Capturar todas las especies normales (ambas gen)
// ============================================================
import Toybox.Lang;
import Toybox.Math;

class LegendaryQuestManager {

    // ── Condiciones ───────────────────────────────────────
    static const STEPS_REQUIRED        = 500000;  // Articuno: ~2 meses
    static const STREAK_REQUIRED       = 30;      // Zapdos: 1 mes
    static const CATCHES_REQUIRED      = 500;     // Moltres: 500 capturas
    // Mewtwo: todos los normales de Kanto (151 - 5 quest legendarios = 146)
    static const KANTO_NORMAL_COUNT    = 146;
    // Gen 2 conditions
    static const DAILY_STEPS_REQUIRED  = 10000;   // Raikou: 10K en un día
    static const MIN_TOTAL_FOR_DAILY   = 50000;   // Mínimo pasos totales antes de activar quest diario
    static const TOTAL_STEPS_GEN2      = 1000000; // Entei: 1M pasos totales
    static const STREAK_GEN2_REQUIRED  = 60;      // Suicune: 60 días racha

    // ── ¿Es un legendario por misión? ─────────────────────
    static function isQuestLegendary(id as Lang.Number) as Lang.Boolean {
        return id == 144 || id == 145 || id == 146 || id == 150 || id == 151
            || id == 243 || id == 244 || id == 245
            || id == 249 || id == 250 || id == 251;
    }

    // ── Verificar si algún legendario se desbloquea ───────
    // Retorna el id del legendario listo, o 0.
    static function checkQuests() as Lang.Number {
        // Gen 1
        if (isReady(144)) { return 144; }
        if (isReady(145)) { return 145; }
        if (isReady(146)) { return 146; }
        if (isReady(150)) { return 150; }
        if (isReady(151)) { return 151; }
        // Gen 2
        if (isReady(243)) { return 243; }
        if (isReady(244)) { return 244; }
        if (isReady(245)) { return 245; }
        if (isReady(249)) { return 249; }
        if (isReady(250)) { return 250; }
        if (isReady(251)) { return 251; }
        return 0;
    }

    // ── ¿El quest está listo para spawnear? ───────────────
    static function isReady(id as Lang.Number) as Lang.Boolean {
        // Ya atrapado → no reaparece
        if (GameState.getCaughtCount(id) > 0) { return false; }
        var status = GameState.getLegendaryStatus(id);
        if (status == 2) { return false; } // marcado como atrapado
        if (status == 1) { return true;  } // ya desbloqueado

        // Evaluar condición
        var met = false;
        if (id == 144) {
            met = GameState.totalStepsAllTime >= STEPS_REQUIRED;
        } else if (id == 145) {
            met = GameState.dailyStreak >= STREAK_REQUIRED;
        } else if (id == 146) {
            met = countTotalCatches() >= CATCHES_REQUIRED;
        } else if (id == 150) {
            met = countNormalUniqueKanto() >= KANTO_NORMAL_COUNT;
        } else if (id == 151) {
            met = GameState.getCaughtCount(144) > 0
               && GameState.getCaughtCount(145) > 0
               && GameState.getCaughtCount(146) > 0;
        } else if (id == 243) {
            // Requiere mínimo de pasos totales para evitar trigger accidental
            met = GameState.totalStepsAllTime >= MIN_TOTAL_FOR_DAILY
               && GameState.getStepsToday() >= DAILY_STEPS_REQUIRED;
        } else if (id == 244) {
            met = GameState.totalStepsAllTime >= TOTAL_STEPS_GEN2;
        } else if (id == 245) {
            met = GameState.dailyStreak >= STREAK_GEN2_REQUIRED;
        } else if (id == 249) {
            met = GameState.getCaughtCount(243) > 0
               && GameState.getCaughtCount(244) > 0
               && GameState.getCaughtCount(245) > 0;
        } else if (id == 250) {
            // Completar Pokédex Kanto: 151 especies (normales + quest)
            met = countKantoCaught() >= 151;
        } else if (id == 251) {
            // Todas las especies normales de ambas generaciones
            met = countNormalUniqueAll() >= countNormalTotal();
        }

        if (met) {
            GameState.setLegendaryStatus(id, 1);
            return true;
        }
        return false;
    }

    // ── Total de capturas individuales ────────────────────
    static function countTotalCatches() as Lang.Number {
        var total = 0;
        for (var i = 1; i <= PokemonData.TOTAL_POKEMON; i++) {
            total += GameState.getCaughtCount(i);
        }
        return total;
    }

    // ── Pokémon normales únicos de Kanto (no quest leg.) ──
    static function countNormalUniqueKanto() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= 151; i++) {
            if (isQuestLegendary(i)) { continue; }
            if (GameState.getCaughtCount(i) > 0) { count++; }
        }
        return count;
    }

    // ── Todas las especies Kanto capturadas ───────────────
    static function countKantoCaught() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= 151; i++) {
            if (GameState.getCaughtCount(i) > 0) { count++; }
        }
        return count;
    }

    // ── Pokémon normales únicos de ambas gen ──────────────
    static function countNormalUniqueAll() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= PokemonData.TOTAL_POKEMON; i++) {
            if (isQuestLegendary(i)) { continue; }
            if (GameState.getCaughtCount(i) > 0) { count++; }
        }
        return count;
    }

    // ── Total de especies normales (no quest leg.) ────────
    static function countNormalTotal() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= PokemonData.TOTAL_POKEMON; i++) {
            if (!isQuestLegendary(i)) { count++; }
        }
        return count;
    }

    // ── Generar encuentro legendario ──────────────────────
    static function spawnLegendary(id as Lang.Number) as Lang.Dictionary {
        var data = PokemonData.get(id);
        var isShiny = (Math.rand() % BalanceConfig.getShinyOdds() == 0);
        return {
            :id      => id,
            :isShiny => isShiny,
            :hpMax   => data[:hp],
            :hpCurr  => data[:hp],
            :stepPowerPercent => 100,
            :stepsAtStart => GameState.getCumulativeSteps()
        };
    }

    // ── Progreso de un quest (0-100%) ─────────────────────
    static function getProgress(id as Lang.Number) as Lang.Number {
        if (GameState.getCaughtCount(id) > 0) { return 100; }
        var pct = 0;
        if (id == 144) {
            pct = (GameState.totalStepsAllTime * 100) / STEPS_REQUIRED;
        } else if (id == 145) {
            pct = (GameState.dailyStreak * 100) / STREAK_REQUIRED;
        } else if (id == 146) {
            pct = (countTotalCatches() * 100) / CATCHES_REQUIRED;
        } else if (id == 150) {
            pct = (countNormalUniqueKanto() * 100) / KANTO_NORMAL_COUNT;
        } else if (id == 151) {
            var have = 0;
            if (GameState.getCaughtCount(144) > 0) { have++; }
            if (GameState.getCaughtCount(145) > 0) { have++; }
            if (GameState.getCaughtCount(146) > 0) { have++; }
            pct = (have * 100) / 3;
        } else if (id == 243) {
            // Progreso combinado: requiere pasos totales mínimos Y pasos diarios
            if (GameState.totalStepsAllTime < MIN_TOTAL_FOR_DAILY) {
                pct = (GameState.totalStepsAllTime * 100) / MIN_TOTAL_FOR_DAILY / 2;
            } else {
                pct = 50 + (GameState.getStepsToday() * 50) / DAILY_STEPS_REQUIRED;
            }
        } else if (id == 244) {
            pct = (GameState.totalStepsAllTime * 100) / TOTAL_STEPS_GEN2;
        } else if (id == 245) {
            pct = (GameState.dailyStreak * 100) / STREAK_GEN2_REQUIRED;
        } else if (id == 249) {
            var have = 0;
            if (GameState.getCaughtCount(243) > 0) { have++; }
            if (GameState.getCaughtCount(244) > 0) { have++; }
            if (GameState.getCaughtCount(245) > 0) { have++; }
            pct = (have * 100) / 3;
        } else if (id == 250) {
            pct = (countKantoCaught() * 100) / 151;
        } else if (id == 251) {
            var normalTotal = countNormalTotal();
            if (normalTotal > 0) {
                pct = (countNormalUniqueAll() * 100) / normalTotal;
            }
        }
        return (pct > 100) ? 100 : pct;
    }

    // ── Descripción corta del quest ───────────────────────
    static function getQuestLabel(id as Lang.Number) as Lang.String {
        if (id == 144) { return "500K pasos"; }
        if (id == 145) { return "30d racha"; }
        if (id == 146) { return "500 capturas"; }
        if (id == 150) { return "146 Kanto"; }
        if (id == 151) { return "3 aves leg."; }
        if (id == 243) { return "10K p/dia"; }
        if (id == 244) { return "1M pasos"; }
        if (id == 245) { return "60d racha"; }
        if (id == 249) { return "3 bestias"; }
        if (id == 250) { return "151 Kanto"; }
        if (id == 251) { return "Dex completa"; }
        return "";
    }
}
