// ============================================================
//  PokeWatch v1 — PokeWatchApp.mc
//  Archivo principal. Arranca la app y gestiona el ciclo de vida.
//  Incluye soporte para notificaciones de fondo.
// ============================================================
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Background;
import Toybox.Time;
import Toybox.Attention;

class PokeWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        try {
            GameState.load();
        } catch (e) {
            // Storage corrupto — reiniciar estado limpio
            GameState.caughtCounts = {};
            GameState.pokedexSeen = [];
            GameState.shinyList = [];
            GameState.stepsAtLastSpawn = 0;
            GameState.stepsAtLastBlock = 0;
            GameState.activityBlocksToday = 0;
            GameState.dailyStreak = 0;
            GameState.lastPlayDate = "";
            GameState.pokemonOfDay = 1;
            GameState.buddyId = 0;
            GameState.buddySteps = 0;
            GameState.buddyLastSteps = 0;
            GameState.pokemonXP = {};
            GameState.totalStepsAllTime = 0;
            GameState.totalStepsLastRef = 0;
            GameState.legendaryStatus = {};
            GameState.currentEncounter = null;
            try { GameState.save(); } catch (e2) {}
        }
    }

    function onStop(state as Lang.Dictionary?) as Void {
        GameState.save();
        // Registrar verificación periódica de spawns en background (5 min)
        try {
            if (Background has :registerForTemporalEvent) {
                Background.registerForTemporalEvent(
                    Time.now().add(new Time.Duration(300))
                );
            }
        } catch (e) {}
    }

    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        return [ new MainView(), new MainDelegate() ];
    }

    // Delegado del servicio de fondo
    (:background)
    function getServiceDelegate() as [ System.ServiceDelegate ] {
        return [ new BackgroundServiceDelegate() ];
    }

    // Recibe datos del servicio de fondo
    function onBackgroundData(data) as Void {
        if (data != null) {
            // Verificar si hay un spawn posible
            GameState.load();
            if (GameState.currentEncounter == null) {
                var steps = GameState.getStepsToday();
                var diff = steps - GameState.stepsAtLastSpawn;
                if (diff < 0) { diff = 0; }
                if (diff >= BalanceConfig.getStepsPerSpawn()) {
                    // Vibrar — hay un posible spawn esperando
                    try {
                        if (Attention has :vibrate) {
                            Attention.vibrate([
                                new Attention.VibeProfile(40, 200),
                                new Attention.VibeProfile(0, 100),
                                new Attention.VibeProfile(40, 200)
                            ]);
                        }
                    } catch (e) {}
                }
            }
        }
        // Re-registrar para la próxima verificación
        try {
            if (Background has :registerForTemporalEvent) {
                Background.registerForTemporalEvent(
                    Time.now().add(new Time.Duration(300))
                );
            }
        } catch (e) {}
    }
}
