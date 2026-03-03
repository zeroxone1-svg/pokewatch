// ============================================================
//  LegendaryQuestManager.mc — Misiones para legendarios.
//
//  Los legendarios NO aparecen por spawn normal.
//  Cada uno requiere cumplir una condición especial.
//
//  Articuno (144): 500,000 pasos totales acumulados
//  Zapdos   (145): Racha de 30 días activos consecutivos
//  Moltres  (146): 500 capturas totales individuales
//  Mewtwo   (150): Todos los Pokémon normales (146 especies)
//  Mew      (151): Capturar Articuno + Zapdos + Moltres
// ============================================================
import Toybox.Lang;
import Toybox.Math;

class LegendaryQuestManager {

    // ── Condiciones ───────────────────────────────────────
    static const STEPS_REQUIRED    = 500000; // Articuno: ~2 meses caminando
    static const STREAK_REQUIRED   = 30;     // Zapdos: 1 mes de racha
    static const CATCHES_REQUIRED  = 500;    // Moltres: 500 capturas totales
    static const NORMAL_COUNT      = 146;    // Mewtwo: IDs 1-143 + 147-149

    // ── ¿Es un legendario por misión? ─────────────────────
    static function isQuestLegendary(id as Lang.Number) as Lang.Boolean {
        return id == 144 || id == 145 || id == 146 || id == 150 || id == 151;
    }

    // ── Verificar si algún legendario se desbloquea ───────
    // Retorna el id del legendario listo, o 0.
    static function checkQuests() as Lang.Number {
        // Aves primero, luego Mewtwo, y Mew al final
        if (isReady(144)) { return 144; }
        if (isReady(145)) { return 145; }
        if (isReady(146)) { return 146; }
        if (isReady(150)) { return 150; }
        if (isReady(151)) { return 151; }
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
            met = countNormalUnique() >= NORMAL_COUNT;
        } else if (id == 151) {
            met = GameState.getCaughtCount(144) > 0
               && GameState.getCaughtCount(145) > 0
               && GameState.getCaughtCount(146) > 0;
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
        for (var i = 1; i <= 151; i++) {
            total += GameState.getCaughtCount(i);
        }
        return total;
    }

    // ── Pokémon normales únicos atrapados ─────────────────
    static function countNormalUnique() as Lang.Number {
        var count = 0;
        for (var i = 1; i <= 151; i++) {
            if (isQuestLegendary(i)) { continue; }
            if (GameState.getCaughtCount(i) > 0) { count++; }
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
            :stepsAtStart => GameState.getStepsToday()
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
            pct = (countNormalUnique() * 100) / NORMAL_COUNT;
        } else if (id == 151) {
            var have = 0;
            if (GameState.getCaughtCount(144) > 0) { have++; }
            if (GameState.getCaughtCount(145) > 0) { have++; }
            if (GameState.getCaughtCount(146) > 0) { have++; }
            pct = (have * 100) / 3;
        }
        return (pct > 100) ? 100 : pct;
    }

    // ── Descripción corta del quest ───────────────────────
    static function getQuestLabel(id as Lang.Number) as Lang.String {
        if (id == 144) { return "500K pasos"; }
        if (id == 145) { return "30d racha"; }
        if (id == 146) { return "500 capturas"; }
        if (id == 150) { return "146 Pokemon"; }
        if (id == 151) { return "3 aves leg."; }
        return "";
    }
}
