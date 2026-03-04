// ============================================================
//  SpawnEngine.mc — Genera encuentros con Pokémon.
//
//  Reglas:
//  - Selección ponderada por tier
//  - Pokémon del día tiene 3x más probabilidad de aparecer
//  - Racha activa: +50% probabilidad de tiers 2-3
//  - Shiny: 1 en 450 por encuentro
//  - HP tiene variación aleatoria ±20%
// ============================================================
import Toybox.Lang;
import Toybox.Math;

class SpawnEngine {

    // Generar un encuentro nuevo
    static function generate() as Lang.Dictionary {
        var id = pickId();
        var isShiny = (Math.rand() % BalanceConfig.getShinyOdds() == 0);
        var data = PokemonData.get(id);
        var activityBlocks = GameState.getActivityBlocksToday();
        var stepPowerPercent = BalanceConfig.getStepPowerPercent(activityBlocks);

        // HP con variación ±20%
        var baseHp = data[:hp];
        var variationPercent = BalanceConfig.getHpVariationPercent();
        var variationRange = (variationPercent * 2) + 1;
        var variation = (Math.rand() % variationRange) - variationPercent;
        var hp = baseHp + (baseHp * variation / 100);

        return {
            :id      => id,
            :isShiny => isShiny,
            :hpMax   => hp,
            :hpCurr  => hp,
            :stepPowerPercent => stepPowerPercent,
            :stepsAtStart => GameState.getStepsToday()
        };
    }

    // ── Selección ponderada ───────────────────────────────
    static function pickId() as Lang.Number {
        // Construir pool de ids con sus pesos
        var pool = buildPool();
        var total = 0;
        for (var i = 0; i < pool.size(); i++) {
            var entry = pool[i] as Lang.Dictionary;
            total += entry[:weight];
        }

        var r = Math.rand() % total;
        var cum = 0;
        for (var i = 0; i < pool.size(); i++) {
            var entry = pool[i] as Lang.Dictionary;
            cum += entry[:weight];
            if (r < cum) {
                return entry[:id];
            }
        }
        return 19; // Rattata como fallback
    }

    // Construye pool con pesos para cada Pokémon
    // Solo incluye formas base (no evolucionadas) para que el
    // jugador las evolucione atrapando duplicados o caminando.
    static function buildPool() as Lang.Array {
        var pool = [];
        var podId = GameState.pokemonOfDay;
        var tierWeights = BalanceConfig.getTierWeights();
        var activityBlocks = GameState.getActivityBlocksToday();
        var hasActivityBonus = BalanceConfig.hasRareBonus(activityBlocks);

        // Construir set de Pokemon que son resultado de evolución
        var evoTargets = {};
        for (var j = 1; j <= PokemonData.TOTAL_POKEMON; j++) {
            var d = PokemonData.get(j);
            var target = d[:evoTo];
            if (target > 0) {
                evoTargets[target] = true;
            } else if (target == -1) {
                // Eevee: 134,135,136,196,197
                evoTargets[134] = true;
                evoTargets[135] = true;
                evoTargets[136] = true;
                evoTargets[196] = true;
                evoTargets[197] = true;
                // Gloom→Vileplume(45)/Bellossom(182)
                evoTargets[45]  = true;
                evoTargets[182] = true;
                // Poliwhirl→Poliwrath(62)/Politoed(186)
                evoTargets[62]  = true;
                evoTargets[186] = true;
                // Slowpoke→Slowbro(80)/Slowking(199)
                evoTargets[80]  = true;
                evoTargets[199] = true;
                // Tyrogue→Hitmonlee(106)/Hitmonchan(107)/Hitmontop(237)
                evoTargets[106] = true;
                evoTargets[107] = true;
                evoTargets[237] = true;
            }
        }

        for (var i = 1; i <= PokemonData.TOTAL_POKEMON; i++) {
            // Excluir Pokemon que son resultado de evolución
            if (evoTargets.hasKey(i)) { continue; }
            // Excluir legendarios por misión (solo aparecen por evento)
            if (LegendaryQuestManager.isQuestLegendary(i)) { continue; }

            var data = PokemonData.get(i);
            var tier = data[:tier];
            var weight = tierWeights[tier];

            // Pokémon del día: 3x
            if (i == podId) {
                weight = weight * BalanceConfig.getPokemonOfDayWeightMultiplier();
            }

            // Bloques activos: tiers 2-3 tienen 50% más peso
            if (hasActivityBonus && BalanceConfig.isRareBonusTier(tier)) {
                weight = BalanceConfig.applyPercentBonus(weight, BalanceConfig.getActivityBonusPercent());
            }

            if (weight > 0) {
                pool.add({:id => i, :weight => weight});
            }
        }
        return pool;
    }

    // ── Daño por pasos ────────────────────────────────────
    // Llamar cada vez que se actualizan los pasos durante un encuentro.
    // Devuelve el HP actualizado.
    static function applyStepDamage(encounter as Lang.Dictionary) as Lang.Dictionary {
        var stepsNow   = GameState.getStepsToday();
        var stepsStart = encounter[:stepsAtStart];
        var stepsDone  = stepsNow - stepsStart;
        if (stepsDone < 0) { stepsDone = 0; }
        var stepPowerPercent = 100;
        if (encounter.hasKey(:stepPowerPercent)) {
            stepPowerPercent = encounter[:stepPowerPercent];
        }

        // Daño = pasos caminados durante el encuentro
        // HP actual = max - daño acumulado
        var totalDamage = (stepsDone * stepPowerPercent) / 100;
        var newHp = encounter[:hpMax] - totalDamage;
        if (newHp < 0) { newHp = 0; }
        if (newHp > encounter[:hpMax]) { newHp = encounter[:hpMax]; }

        encounter[:hpCurr] = newHp;
        return encounter;
    }

    // ── ¿Pokémon debilitado? ──────────────────────────────
    static function isDefeated(encounter as Lang.Dictionary) as Lang.Boolean {
        return encounter[:hpCurr] <= 0;
    }

    // ── % de HP restante ──────────────────────────────────
    static function hpPercent(encounter as Lang.Dictionary) as Lang.Number {
        if (encounter[:hpMax] <= 0) { return 0; }
        return (encounter[:hpCurr] * 100) / encounter[:hpMax];
    }
}
