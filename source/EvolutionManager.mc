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

        // Eevee: evolución aleatoria entre 134, 135, 136
        if (evoTo == -1) {
            var opts = [134, 135, 136];
            return opts[Math.rand() % 3];
        }

        return evoTo;
    }

    static function getRequiredCount(id as Lang.Number) as Lang.Number {
        var data = PokemonData.get(id);
        return BalanceConfig.getEffectiveEvolutionCost(data[:evoCost]);
    }

    // Ejecutar la evolución: añade 1 al nuevo Pokémon en la dex.
    static function evolve(fromId as Lang.Number, toId as Lang.Number) as Void {
        GameState.registerCatch(toId, false);
        // Opcional: podrías resetear el contador del fromId aquí
        // para que el jugador tenga que volver a capturar.
        // Por ahora lo dejamos acumulativo.
    }
}
