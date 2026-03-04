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
import Toybox.Attention;

class EncounterView extends WatchUi.View {

    var _timer    as Timer.Timer;
    var _captured as Lang.Boolean = false;
    var _evolved  as Lang.Number  = 0; // id al que evolucionó, 0 = nada
    var _shouldPop as Lang.Boolean = false;
    var _isNew    as Lang.Boolean = false; // true si es un Pokemon nuevo
    var _capturedId as Lang.Number = 0; // id del Pokemon capturado para mostrar sprite
    var _animFrame as Lang.Number = 0; // frame de animación para bobbing

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
        // Verificar si es un Pokemon nuevo al entrar
        if (GameState.currentEncounter != null) {
            var enc = GameState.currentEncounter;
            _isNew = (GameState.getCaughtCount(enc[:id]) == 0);
        }
    }

    function onShow() as Void {
        // Actualizar cada 1.5 segundos para animación y HP
        _timer.start(method(:onTimer), 1500, true);
    }

    function onHide() as Void {
        _timer.stop();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function onTimer() as Void {
        // Manejar pop diferido (no se puede hacer popView dentro de onUpdate)
        if (_shouldPop) {
            _shouldPop = false;
            _timer.stop();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }
        _animFrame = (_animFrame + 1) % 4;
        if (!_captured && GameState.currentEncounter != null) {
            // Actualizar daño
            GameState.currentEncounter = SpawnEngine.applyStepDamage(
                GameState.currentEncounter
            );
            // ¿Debilitado?
            if (SpawnEngine.isDefeated(GameState.currentEncounter)) {
                _captured = true;
                var enc = GameState.currentEncounter;
                _capturedId = enc[:id];
                GameState.registerCatch(enc[:id], enc[:isShiny]);
                // Revisar evolución
                _evolved = EvolutionManager.checkEvolution(enc[:id]);
                if (_evolved > 0) {
                    EvolutionManager.evolve(enc[:id], _evolved);
                }
                GameState.currentEncounter = null;
                GameState.save();
                // Vibrar al capturar
                vibrateCatch(_evolved > 0);
            }
        }
        WatchUi.requestUpdate();
    }

    // Vibrar al capturar (más fuerte si evoluciona)
    function vibrateCatch(evolved as Lang.Boolean) as Void {
        try {
            if (Attention has :vibrate) {
                if (evolved) {
                    Attention.vibrate([
                        new Attention.VibeProfile(50, 200),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400)
                    ]);
                } else {
                    Attention.vibrate([
                        new Attention.VibeProfile(50, 300),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(50, 200)
                    ]);
                }
            }
        } catch (e) {}
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();   // 360
        var h = dc.getHeight();  // 360
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // ── Fondo Game Boy (escenario batalla) ───────────
        drawBattleBackground(dc, w, h);

        // ── Pantalla de captura exitosa ───────────────────
        if (_captured) {
            drawCaptureScreen(dc, w, h);
            return;
        }

        if (GameState.currentEncounter == null && !_captured) {
            // Diferir el popView al timer — no se puede llamar dentro de onUpdate
            _shouldPop = true;
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

        // ── SPRITE centrado (100x100) con bobbing solo en bitmap ─
        var spriteSize = 100;
        var spriteY    = 70;
        var bobOffsets = [0, -2, 0, 2];
        var bob = bobOffsets[_animFrame];
        dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 56, spriteY - 4, 112, 112, 10);
        // Borde dorado si es shiny, color tier si no
        var spriteBorder = isShiny ? 0xFFD700 : 0x333333;
        if (_animFrame == 1 || _animFrame == 3) {
            spriteBorder = isShiny ? 0xFFE84D : 0x444444;
        }
        dc.setColor(spriteBorder, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(cx - 56, spriteY - 4, 112, 112, 10);
        if (isShiny) {
            dc.drawRoundedRectangle(cx - 57, spriteY - 5, 114, 114, 11);
        }
        var sprite     = SpriteManager.getSprite(id);
        if (sprite != null) {
            // Solo el sprite se mueve con bob, la caja queda fija
            dc.drawBitmap(cx - spriteSize / 2, spriteY + bob, sprite as WatchUi.BitmapResource);
        } else {
            dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, spriteY + 30, Graphics.FONT_NUMBER_THAI_HOT,
                "#" + id.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Posición fija después del sprite (sin bob)
        var afterY = spriteY + spriteSize + 12;
        if (isShiny) {
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, afterY, Graphics.FONT_XTINY,
                tr(Rez.Strings.Shiny), Graphics.TEXT_JUSTIFY_CENTER);
            afterY += 22;
        }

        // ── Barra de HP (centrada, limpia) ──────────────
        var hpCurr = enc[:hpCurr];
        var hpMax  = enc[:hpMax];
        var barW  = 140;
        var barX  = cx - barW / 2;
        var barY  = afterY;
        var barH  = 10;
        var fillW = (hpPct * barW) / 100;

        var hpColor = 0x44CC44;
        if (hpPct < 50) { hpColor = 0xFFCC00; }
        if (hpPct < 25) { hpColor = 0xFF4444; }

        dc.setColor(0x262626, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barW, barH, 4);
        if (fillW > 0) {
            dc.setColor(hpColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, fillW, barH, 4);
        }

        // ── HP números debajo de la barra ─────────────────
        var hpNumY = barY + barH + 2;
        dc.setColor(hpColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hpNumY, Graphics.FONT_XTINY,
            "HP " + hpCurr.toString() + " / " + hpMax.toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── Info: pasos + distancia (debajo de HP) ────────
        var infoY = hpNumY + 22;
        var meters = (stepsInEnc * 75) / 100;
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, infoY, Graphics.FONT_XTINY,
            stepsInEnc.toString() + " pasos  ~" + meters.toString() + "m",
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── Mensaje motivación ─────────────────────────────
        var msgY = infoY + 20;
        var msg = tr(Rez.Strings.KeepWalking);
        if (hpPct < 25) { msg = tr(Rez.Strings.AlmostThere); }
        if (hpPct < 10) { msg = tr(Rez.Strings.FinalSteps); }
        dc.setColor(0x44CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, msgY, Graphics.FONT_XTINY, msg,
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

        var isLegQuest = (_capturedId > 0) && LegendaryQuestManager.isQuestLegendary(_capturedId);

        // Fondo sutil circular (más compacto)
        if (isLegQuest) {
            dc.setColor(0x221A00, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy + 10, 100);
            dc.setColor(0x332A00, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(cx, cy + 10, 100);
        } else {
            dc.setColor(0x002200, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy + 10, 100);
            dc.setColor(0x003300, Graphics.COLOR_TRANSPARENT);
            dc.drawCircle(cx, cy + 10, 100);
        }

        // Sprite del Pokemon capturado (arriba, fuera del círculo)
        if (_capturedId > 0) {
            var sprite = SpriteManager.getSprite(_capturedId);
            if (sprite != null) {
                dc.drawBitmap(cx - 40, 30, sprite as WatchUi.BitmapResource);
            }
        }

        // Texto ATRAPADO!
        if (isLegQuest) {
            dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 20, Graphics.FONT_SMALL,
                tr(Rez.Strings.QuestLegendary), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x44FF44, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 20, Graphics.FONT_SMALL,
                tr(Rez.Strings.CaughtTitle), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Pokedex count
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 14, Graphics.FONT_XTINY,
            GameState.uniqueCaught().toString() + "/" + PokemonData.TOTAL_POKEMON.toString() + " " + tr(Rez.Strings.InYourPokedex),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Badge NUEVO debajo del conteo
        var nextLineY = cy + 36;
        if (_isNew) {
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, nextLineY, Graphics.FONT_XTINY,
                tr(Rez.Strings.NewPokemon), Graphics.TEXT_JUSTIFY_CENTER);
            nextLineY += 20;
        }

        // Evolución debajo de todo
        if (_evolved > 0) {
            dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, nextLineY, Graphics.FONT_XTINY,
                tr(Rez.Strings.Evolution) + " -> " + PokemonData.getName(_evolved).toUpper(),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(0x336633, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h - 50, Graphics.FONT_XTINY,
            tr(Rez.Strings.TapToContinue), Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Dibujar fondo estilo batalla GameBoy (bitmap) ─────────
    function drawBattleBackground(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        try {
            var bg = WatchUi.loadResource(Rez.Drawables.bg_battle) as WatchUi.BitmapResource;
            dc.drawBitmap(0, 0, bg);
        } catch (e) {
            // fallback: fondo negro si no se puede cargar
        }
    }
}

// ── Delegado ────────────────────────────────────────────────
class EncounterDelegate extends WatchUi.BehaviorDelegate {
    var _view as EncounterView;

    function initialize(view as EncounterView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Tap → continuar cuando ya capturó
    function onSelect() as Lang.Boolean {
        if (_view._captured) {
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
