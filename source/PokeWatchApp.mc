// ============================================================
//  PokeWatch v1 — PokeWatchApp.mc
//  Archivo principal. Arranca la app y gestiona el ActivitySession.
// ============================================================
import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;

class PokeWatchApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Lang.Dictionary?) as Void {
        // Carga el estado guardado al iniciar
        GameState.load();
    }

    function onStop(state as Lang.Dictionary?) as Void {
        // Guarda el estado al cerrar
        GameState.save();
    }

    function getInitialView() as [ WatchUi.Views ] or [ WatchUi.Views, WatchUi.InputDelegates ] {
        return [ new MainView(), new MainDelegate() ];
    }
}
