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

    // ── XP / Level System ─────────────────────────────────
    //
    //  Crecimiento variable por tier (como los juegos):
    //    Tier 0 (Común):      100 XP/nivel — suben rápido
    //    Tier 1 (Poco común): 200 XP/nivel
    //    Tier 2 (Raro):       350 XP/nivel
    //    Tier 3 (Muy raro):   550 XP/nivel — suben lento
    //    Tier 4 (Legendario): 800 XP/nivel
    //
    //  Niveles de evolución (parecido a los juegos):
    //    evoCost 25  → Lv.7   (Caterpie, Weedle, Pidgey…)
    //    evoCost 50  → Lv.18  (Nidorina, Gloom, Haunter…)
    //    evoCost 100 → Lv.25  (Pikachu, Eevee, Kadabra…)
    //    evoCost 150 → Lv.40  (Dragonair)
    //    evoCost 400 → Lv.20  (Magikarp → Gyarados)
    //
    //  Ejemplos resultantes:
    //    Caterpie  (tier 0, Lv.7)  → 600 XP  → 3 capturas ✓
    //    Nidorina  (tier 1, Lv.18) → 3400 XP → ~10 capturas
    //    Pikachu   (tier 2, Lv.25) → 8400 XP → ~17 capturas
    //    Dragonair (tier 3, Lv.40) → 21450XP → ~27 capturas
    //    Magikarp  (tier 0, Lv.20) → 1900 XP → ~10 capturas

    // XP que necesita un Pokémon para subir 1 nivel, según su tier
    static function getXPPerLevel(tier as Lang.Number) as Lang.Number {
        var xpByTier = [100, 200, 350, 550, 800];
        return xpByTier[tier];
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

    // Level from total XP (variable por tier, max 100)
    static function getLevelFromXP(xp as Lang.Number, tier as Lang.Number) as Lang.Number {
        var perLevel = getXPPerLevel(tier);
        var level = 1 + (xp / perLevel);
        if (level > 100) { level = 100; }
        return level;
    }

    // XP needed to reach a given level (variable por tier)
    static function getXPForLevel(level as Lang.Number, tier as Lang.Number) as Lang.Number {
        var perLevel = getXPPerLevel(tier);
        return (level - 1) * perLevel;
    }

    // Nivel requerido para evolucionar según el evoCost base
    //   (alineado con los juegos originales)
    static function getEvolutionLevel(baseCost as Lang.Number) as Lang.Number {
        if (baseCost <= 0) { return 0; }
        if (baseCost <= 25) { return 7; }   // Caterpie Lv.7, Pidgey Lv.7…
        if (baseCost <= 50) { return 18; }  // Nidorina Lv.18, Gloom Lv.18…
        if (baseCost <= 100) { return 25; } // Pikachu Lv.25, Eevee Lv.25…
        if (baseCost <= 150) { return 40; } // Dragonair Lv.40
        return 20;                          // Magikarp Lv.20 (caso especial)
    }
}
