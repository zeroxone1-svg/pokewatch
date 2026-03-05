// ============================================================
//  BalanceConfig.mc — Punto único de ajuste de gameplay.
// ============================================================
import Toybox.Lang;

class BalanceConfig {

    // Presets
    static const PRESET_CASUAL = 0;
    static const PRESET_MEDIUM = 1;
    static const PRESET_CHALLENGING = 2;

    // Cambia solo esta línea para ajustar toda la dificultad.
    static const ACTIVE_PRESET = PRESET_MEDIUM;

    static function getStepsPerSpawn() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 400; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 750; }
        return 500;
    }

    static function getSpawnRollDenominator() as Lang.Number {
        return 10;
    }

    static function getSpawnRollSuccessMax() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 8; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 6; }
        return 7;
    }

    static function getSpawnRollSuccessMaxForBlocks(activityBlocks as Lang.Number) as Lang.Number {
        if (hasRareBonus(activityBlocks)) {
            var boosted = getSpawnRollSuccessMax() + 1;
            var cap = getSpawnRollDenominator() - 1;
            return (boosted > cap) ? cap : boosted;
        }
        return getSpawnRollSuccessMax();
    }

    static function getStepsPerActivityBlock() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 500; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 700; }
        return 600;
    }

    static function getActivityBonusMinBlocks() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 3; }
        return 2;
    }

    static function getActivityBonusPercent() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 60; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 45; }
        return 50;
    }

    static function getTierWeights() as Lang.Array {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return [60, 24, 10, 5, 1]; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return [50, 26, 14, 8, 2]; }
        return [55, 25, 12, 6, 2];
    }

    static function getPokemonOfDayWeightMultiplier() as Lang.Number {
        return 3;
    }

    static function getShinyOdds() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 360; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 600; }
        return 450;
    }

    static function getHpVariationPercent() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 15; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 25; }
        return 20;
    }

    static function getStepPowerPercent(activityBlocks as Lang.Number) as Lang.Number {
        if (hasRareBonus(activityBlocks)) {
            return 115;
        }
        return 100;
    }

    static function getEvolutionCostDivisor() as Lang.Number {
        if (ACTIVE_PRESET == PRESET_CASUAL) { return 4; }
        if (ACTIVE_PRESET == PRESET_CHALLENGING) { return 2; }
        return 3;
    }

    static function getEvolutionMinCost() as Lang.Number {
        return 3;
    }

    static function getEffectiveEvolutionCost(baseCost as Lang.Number) as Lang.Number {
        if (baseCost <= 0) { return 0; }

        var divisor = getEvolutionCostDivisor();
        var reduced = (baseCost + divisor - 1) / divisor;
        var minCost = getEvolutionMinCost();
        if (reduced < minCost) { reduced = minCost; }
        return reduced;
    }

    static function hasRareBonus(activityBlocks as Lang.Number) as Lang.Boolean {
        return activityBlocks >= getActivityBonusMinBlocks();
    }

    static function isRareBonusTier(tier as Lang.Number) as Lang.Boolean {
        return tier >= 2 && tier <= 3;
    }

    static function applyPercentBonus(baseValue as Lang.Number, percent as Lang.Number) as Lang.Number {
        return baseValue + (baseValue * percent / 100);
    }

    // ── XP / Level System (Curva exponencial) ────────────
    //
    //  Fórmula: XP acumulado para nivel N = sum(base * n * intSqrt(n) / 10, n=1..N-1)
    //  Bases por tier: [30, 55, 90, 140, 200]
    //
    //  Primeros niveles suben rápido, los últimos requieren dedicación real.

    // Base de curva XP por tier
    static function getXPBase(tier as Lang.Number) as Lang.Number {
        var bases = [30, 55, 90, 140, 200];
        return bases[tier];
    }

    // Raíz cuadrada entera (Newton's method, solo enteros)
    static function intSqrt(n as Lang.Number) as Lang.Number {
        if (n <= 0) { return 0; }
        if (n == 1) { return 1; }
        var x = n;
        var y = (x + 1) / 2;
        while (y < x) {
            x = y;
            y = (x + n / x) / 2;
        }
        return x;
    }

    // XP acumulado total necesario para alcanzar un nivel dado
    static function getXPForLevel(level as Lang.Number, tier as Lang.Number) as Lang.Number {
        if (level <= 1) { return 0; }
        var base = getXPBase(tier);
        var total = 0;
        for (var n = 1; n < level; n++) {
            total += base * n * intSqrt(n) / 10;
        }
        return total;
    }

    // Level from total XP (búsqueda binaria, max 7 iteraciones)
    static function getLevelFromXP(xp as Lang.Number, tier as Lang.Number) as Lang.Number {
        if (xp <= 0) { return 1; }
        var lo = 1;
        var hi = 100;
        while (lo < hi) {
            var mid = (lo + hi + 1) / 2;
            if (getXPForLevel(mid, tier) <= xp) {
                lo = mid;
            } else {
                hi = mid - 1;
            }
        }
        if (lo > 100) { lo = 100; }
        return lo;
    }

    // XP awarded to the caught Pokémon on each catch
    static function getCatchXP(tier as Lang.Number) as Lang.Number {
        var xpByTier = [200, 350, 500, 800, 1500];
        return xpByTier[tier];
    }

    // Bonus XP para el buddy al capturar de la misma familia
    static function getBuddyBonusXP(tier as Lang.Number) as Lang.Number {
        var xpByTier = [150, 250, 400, 600, 1000];
        return xpByTier[tier];
    }

    // Nivel requerido para evolucionar según el evoCost base
    static function getEvolutionLevel(baseCost as Lang.Number) as Lang.Number {
        if (baseCost <= 0) { return 0; }
        if (baseCost <= 25) { return 7; }
        if (baseCost <= 50) { return 18; }
        if (baseCost <= 100) { return 25; }
        if (baseCost <= 150) { return 40; }
        return 20;
    }

    // ── Battle System constants ───────────────────────────

    // Trainer spawn chance (15% of spawns are trainers)
    static function getTrainerSpawnPercent() as Lang.Number {
        return 15;
    }

    // Gym data: [name, pokemonId, level, baseSteps, timeSec, unlock, xpReward]
    // unlock > 0 = rival wins required; unlock < 0 = -(previous badge index)
    static const GYM_DATA = [
        ["Brock",    95, 14, 2000, 2700,   0,   500],
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
        ["Lance",   149, 95,16000, 7200, -19, 20000]
    ];

    static const GYM_COUNT = 20;
}
