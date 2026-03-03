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
}
