// ============================================================
//  BackgroundService.mc — Servicio de fondo para notificaciones.
//  Se ejecuta cada 5 minutos para verificar si hay un spawn
//  posible y alertar al usuario con vibración.
// ============================================================
import Toybox.Background;
import Toybox.System;
import Toybox.Lang;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        // Simplemente notificar al app para que verifique.
        // La lógica de verificación real se ejecuta en
        // onBackgroundData() donde hay acceso completo al API.
        Background.exit(true);
    }
}
