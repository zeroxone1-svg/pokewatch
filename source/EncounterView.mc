// ============================================================
//  EncounterView.mc — Pantalla de encuentro con Pokémon.
//
//  Muestra:
//    - Nombre del Pokémon (★ si es shiny)
//    - Tier / rareza
//    - Barra de HP que baja con tus pasos
//    - Pasos que llevas en el encuentro
//    - Salir del encuentro con gesto (swipe izquierda)
//
//  Cuando HP llega a 0 → captura automática.
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;

class EncounterView extends WatchUi.View {

    var _timer    as Timer.Timer;
    var _captured as Lang.Boolean = false;
    var _evolved  as Lang.Number  = 0; // id al que evolucionó, 0 = nada

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onShow() as Void {
        // Actualizar cada 5 segundos para refrescar HP
        _timer.start(method(:onTimer), 5000, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function onTimer() as Void {
        if (!_captured && GameState.currentEncounter != null) {
            // Actualizar daño
            GameState.currentEncounter = SpawnEngine.applyStepDamage(
                GameState.currentEncounter
            );
            // ¿Debilitado?
            if (SpawnEngine.isDefeated(GameState.currentEncounter)) {
                _captured = true;
                var enc = GameState.currentEncounter;
                GameState.registerCatch(enc[:id], enc[:isShiny]);
                // Revisar evolución
                _evolved = EvolutionManager.checkEvolution(enc[:id]);
                if (_evolved > 0) {
                    EvolutionManager.evolve(enc[:id], _evolved);
                }
                GameState.currentEncounter = null;
                GameState.save();
            }
        }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();   // 360
        var h = dc.getHeight();  // 360
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // ── Pantalla de captura exitosa ───────────────────
        if (_captured) {
            drawCaptureScreen(dc, w, h);
            return;
        }

        if (GameState.currentEncounter == null) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }

        var enc     = GameState.currentEncounter;
        var id      = enc[:id];
        var isShiny = enc[:isShiny];
        var hpPct   = SpawnEngine.hpPercent(enc);
        var data    = PokemonData.get(id);
        var tier    = data[:tier];
        var name    = PokemonData.getName(id);
        var stepsNow   = GameState.getStepsToday();
        var stepsInEnc = stepsNow - enc[:stepsAtStart];

        var tierNames  = [
            tr(Rez.Strings.TierCommon),
            tr(Rez.Strings.TierUncommon),
            tr(Rez.Strings.TierRare),
            tr(Rez.Strings.TierVeryRare),
            tr(Rez.Strings.TierLegendary)
        ];
        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var tierColor  = tierColors[tier];

        dc.setColor(0x141414, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(60, 8, w - 120, 54, 8);

        // ── Nombre + shiny (top) ──────────────────────
        var displayName = isShiny ? ("★ " + name.toUpper()) : name.toUpper();
        var nameColor   = isShiny ? 0xFFD700 : Graphics.COLOR_WHITE;
        dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 12, Graphics.FONT_XTINY,
            displayName, Graphics.TEXT_JUSTIFY_CENTER);

        // ── Tier (debajo del nombre, 34px gap) ────────────
        dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 38, Graphics.FONT_XTINY,
            tierNames[tier] + "  #" + id.format("%03d"),
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── SPRITE centrado (120x120) ─────────────────
        var spriteSize = 120;
        var spriteY    = 66;
        dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 66, spriteY - 4, 132, 132, 10);
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(cx - 66, spriteY - 4, 132, 132, 10);
        var sprite     = SpriteManager.getSprite(id);
        if (sprite != null) {
            dc.drawBitmap(cx - spriteSize / 2, spriteY, sprite as WatchUi.BitmapResource);
        } else {
            dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, spriteY + 34, Graphics.FONT_NUMBER_THAI_HOT,
                "#" + id.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Posición dinámica después del sprite
        var afterY = spriteY + spriteSize + 2; // 188
        if (isShiny) {
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, afterY, Graphics.FONT_XTINY,
                tr(Rez.Strings.Shiny), Graphics.TEXT_JUSTIFY_CENTER);
            afterY += 28;
        }

        // ── Barra de HP ───────────────────────────────
        var barW  = 160;
        var barX  = (w - barW) / 2;
        var barY  = afterY;
        var fillW = (hpPct * barW) / 100;

        var hpColor = 0x44CC44;
        if (hpPct < 50) { hpColor = 0xFFCC00; }
        if (hpPct < 25) { hpColor = 0xFF4444; }

        dc.setColor(0x262626, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barW, 14, 6);
        if (fillW > 0) {
            dc.setColor(hpColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, fillW, 14, 6);
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, barY - 1, Graphics.FONT_XTINY,
            hpPct.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);

        // ── Info + mensaje (debajo de HP) ──────────────────
        var infoY = barY + 20;
        dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 95, infoY - 4, 190, 54, 6);
        dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, infoY, Graphics.FONT_XTINY,
            stepsInEnc.toString() + " " + tr(Rez.Strings.EncounterSteps),
            Graphics.TEXT_JUSTIFY_CENTER);

        var msg = tr(Rez.Strings.KeepWalking);
        if (hpPct < 25) { msg = tr(Rez.Strings.AlmostThere); }
        if (hpPct < 10) { msg = tr(Rez.Strings.FinalSteps); }
        dc.setColor(0x44CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, infoY + 26, Graphics.FONT_XTINY, msg,
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── Botón huir (zona segura para pantalla redonda) ─
        var fleeY = h - 78;
        dc.setColor(0x331111, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 70, fleeY - 4, 140, 30, 6);
        dc.setColor(0xFF8888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, fleeY, Graphics.FONT_XTINY,
            tr(Rez.Strings.SwipeLeftFlee), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Pantalla de captura exitosa ───────────────────────
    function drawCaptureScreen(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var cx = w / 2;
        var cy = h / 2;

        // Fondo sutil circular
        dc.setColor(0x002200, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, 140);

        dc.setColor(0x44FF44, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 70, Graphics.FONT_SMALL,
            tr(Rez.Strings.CaughtTitle), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(0x66FF66, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 100, Graphics.FONT_XTINY,
            tr(Rez.Strings.ActiveProgress), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_XTINY,
            GameState.uniqueCaught().toString() + "/151 " + tr(Rez.Strings.InYourPokedex),
            Graphics.TEXT_JUSTIFY_CENTER);

        if (_evolved > 0) {
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 20, Graphics.FONT_XTINY,
                tr(Rez.Strings.Evolution), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 38, Graphics.FONT_XTINY,
                "-> " + PokemonData.getName(_evolved).toUpper(),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(0x336633, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h - 50, Graphics.FONT_XTINY,
            tr(Rez.Strings.TapToContinue), Graphics.TEXT_JUSTIFY_CENTER);
    }
}

// ── Delegado ────────────────────────────────────────────────
class EncounterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Tap → continuar cuando ya capturó
    function onSelect() as Lang.Boolean {
        var view = WatchUi.getCurrentView()[0] as EncounterView;

        if (view._captured) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }

        // Evitar pérdida accidental por tap.
        return true;
    }

    function onNextPage() as Lang.Boolean {
        if (GameState.currentEncounter != null) {
            GameState.currentEncounter = null;
            GameState.save();
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onBack() as Lang.Boolean {
        // Permitir volver sin perder el encuentro.
        return false;
    }
}
