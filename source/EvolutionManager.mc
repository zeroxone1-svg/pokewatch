// ============================================================
//  EvolutionManager.mc — Revisa y ejecuta evoluciones.
// ============================================================
import Toybox.Lang;
import Toybox.Math;

class EvolutionManager {

    // Revisar si el Pokémon id puede evolucionar con las
    // capturas actuales. Devuelve el id al que evoluciona, o 0.
    static function checkEvolution(id as Lang.Number) as Lang.Number {
        var data   = PokemonData.get(id);
        var evoTo  = data[:evoTo];
        var baseCost = data[:evoCost];
        var cost   = BalanceConfig.getEffectiveEvolutionCost(baseCost);

        if (evoTo == 0 || cost <= 0) { return 0; } // no evoluciona

        var caught = GameState.getCaughtCount(id);

        if (caught < cost) { return 0; } // no suficientes capturas

        // Branching evolution (evoTo == -1)
        if (evoTo == -1) {
            return pickBranchEvolution(id);
        }

        return evoTo;
    }

    // Elige aleatoriamente una de las evoluciones posibles
    // para Pokémon con múltiples ramas evolutivas.
    static function pickBranchEvolution(id as Lang.Number) as Lang.Number {
        if (id == 133) {
            // Eevee → Vaporeon/Jolteon/Flareon/Espeon/Umbreon
            var opts = [134, 135, 136, 196, 197];
            return opts[Math.rand() % 5];
        } else if (id == 44) {
            // Gloom → Vileplume/Bellossom
            var opts = [45, 182];
            return opts[Math.rand() % 2];
        } else if (id == 61) {
            // Poliwhirl → Poliwrath/Politoed
            var opts = [62, 186];
            return opts[Math.rand() % 2];
        } else if (id == 79) {
            // Slowpoke → Slowbro/Slowking
            var opts = [80, 199];
            return opts[Math.rand() % 2];
        } else if (id == 236) {
            // Tyrogue → Hitmonlee/Hitmonchan/Hitmontop
            var opts = [106, 107, 237];
            return opts[Math.rand() % 3];
        }
        return 0; // fallback
    }

    static function getRequiredCount(id as Lang.Number) as Lang.Number {
        var data = PokemonData.get(id);
        return BalanceConfig.getEffectiveEvolutionCost(data[:evoCost]);
    }

    // Ejecutar la evolución: añade 1 al nuevo Pokémon en la dex.
    // Resta el costo de evolución del Pokémon base.
    static function evolve(fromId as Lang.Number, toId as Lang.Number) as Void {
        GameState.registerEvolution(toId);
        // Restar el costo del conteo para no disparar evoluciones repetidas
        var cost = getRequiredCount(fromId);
        var key = fromId.toString();
        var current = GameState.getCaughtCount(fromId);
        var newCount = current - cost;
        if (newCount < 0) { newCount = 0; }
        GameState.caughtCounts[key] = newCount;
    }
}
