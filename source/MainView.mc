// ============================================================
//  MainView.mc — Pantalla principal rediseñada
//  Layout limpio para Vivoactive 6 (360x360)
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;

class MainView extends WatchUi.View {

    var _timer as Timer.Timer;

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onLayout(dc as Graphics.Dc) as Void {}

    function onShow() as Void {
        _timer.start(method(:onTimer), 10000, true);
        checkSpawn();
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTimer() as Void {
        GameState.updateActivityBlocks();
        checkSpawn();
        WatchUi.requestUpdate();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function checkSpawn() as Void {
        if (GameState.shouldSpawn()) {
            var blocks = GameState.getActivityBlocksToday();
            var spawnSuccessMax = BalanceConfig.getSpawnRollSuccessMaxForBlocks(blocks);
            if ((Math.rand() % BalanceConfig.getSpawnRollDenominator()) < spawnSuccessMax) {
                var encounter = SpawnEngine.generate();
                GameState.registerSeen(encounter[:id]);
                GameState.currentEncounter = encounter;
                GameState.markSpawn();
                // No auto-push: el usuario ve el pokemon en MainView
                // y entra al encuentro con tap
                WatchUi.requestUpdate();
            }
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w  = dc.getWidth();   // 360
        var h  = dc.getHeight();  // 360
        var cx = w / 2;           // 180

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var steps  = GameState.getStepsToday();
        var blocks = GameState.getActivityBlocksToday();
        var nextIn = GameState.stepsUntilNext();
        var unique = GameState.uniqueCaught();
        var streak = GameState.dailyStreak;

        // Si hay encuentro activo, mostrar ESE Pokémon (no el del día)
        var hasEncounter = (GameState.currentEncounter != null);
        var displayId;
        if (hasEncounter) {
            displayId = GameState.currentEncounter[:id];
        } else {
            displayId = GameState.pokemonOfDay;
        }

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var displayData = PokemonData.get(displayId);
        var displayTier = displayData[:tier];
        var tierColor   = tierColors[displayTier];

        // ── Layout vertical (34px entre líneas de texto) ──
        var titleY   = 30;
        var stepsY   = 54;
        var spriteY  = 78;
        var spriteH  = 120;
        var nameY    = spriteY + spriteH + 2;   // 200
        var infoY    = nameY + 56;              // 256
        var info2Y   = infoY + 28;              // 284
        var footY    = 316;

        // ── CABECERA ──────────────────────────────────────
        dc.setColor(0x151515, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(70, titleY - 6, w - 140, 50, 8);
        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_XTINY,
            "POKEWATCH", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, stepsY, Graphics.FONT_XTINY,
            steps.toString() + " " + tr(Rez.Strings.LabelSteps),
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── SPRITE centrado (120x120) ─────────────────────
        dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - 66, spriteY - 4, 132, 132, 10);
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(cx - 66, spriteY - 4, 132, 132, 10);
        var displaySprite = SpriteManager.getSprite(displayId);
        if (displaySprite != null) {
            dc.drawBitmap(cx - spriteH / 2, spriteY, displaySprite as WatchUi.BitmapResource);
        } else {
            dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, spriteY + 34, Graphics.FONT_NUMBER_THAI_HOT,
                "#" + displayId.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // ── NOMBRE (debajo del sprite) ────────────────────
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, nameY, Graphics.FONT_XTINY,
            PokemonData.getName(displayId).toUpper(),
            Graphics.TEXT_JUSTIFY_CENTER);        // Etiqueta sutil para indicar que es el pokemon del día
        if (!hasEncounter) {
            dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, nameY + 26, Graphics.FONT_XTINY,
                "Pokemon del dia", Graphics.TEXT_JUSTIFY_CENTER);
        }
        // ── ALERTA ENCUENTRO o PRÓXIMO ────────────────────
        if (hasEncounter) {
            dc.setColor(0x5A1212, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(cx - 90, infoY - 4, 180, 58, 6);
            dc.setColor(0xFF6666, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                tr(Rez.Strings.EncounterReady), Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, info2Y, Graphics.FONT_XTINY,
                tr(Rez.Strings.TapToEnter), Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(cx - 100, infoY - 4, 200, 58, 6);
            dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                tr(Rez.Strings.NextIn) + " " + nextIn.toString() + " " + tr(Rez.Strings.LabelSteps),
                Graphics.TEXT_JUSTIFY_CENTER);
            var bonusTxt = BalanceConfig.hasRareBonus(blocks) ? "BONUS ACTIVO" : "CAMINA PARA BONUS";
            dc.setColor(0x44CCFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, info2Y, Graphics.FONT_XTINY, bonusTxt,
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        // ── PIE: DEX y RACHA ─────────────────────────────
        dc.setColor(0x1B1B1B, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(60, footY - 4, w - 120, 30, 6);
        dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 54, footY, Graphics.FONT_XTINY,
            unique.toString() + "/151", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0xFF8800, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 54, footY, Graphics.FONT_XTINY,
            streak.toString() + tr(Rez.Strings.LabelStreakDays),
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Lang.Boolean {
        if (GameState.currentEncounter != null) {
            WatchUi.pushView(
                new EncounterView(),
                new EncounterDelegate(),
                WatchUi.SLIDE_UP
            );
            return true;
        }
        return false;
    }

    function onNextPage() as Lang.Boolean {
        WatchUi.pushView(
            new PokedexView(),
            new PokedexDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        WatchUi.pushView(
            new ProfileView(),
            new ProfileDelegate(),
            WatchUi.SLIDE_DOWN
        );
        return true;
    }
}
