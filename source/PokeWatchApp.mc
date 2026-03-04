// ============================================================
//  PokeWatch v1 — PokeWatchApp.mc
//  Archivo principal. Arranca la app y gestiona el ciclo de vida.
// ============================================================
import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

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
    }

    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        return [ new MainView(), new MainDelegate() ];
    }
}
