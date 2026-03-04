// ============================================================
//  MainView.mc — Pantalla principal con Buddy System
//  Layout para Vivoactive 6 (360x360 redonda)
//  - Fondo dinámico por hora del día
//  - Arco circular de progreso hacia próximo spawn
//  - Buddy con barra de evolución
//  - Alerta animada de encuentro
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;
import Toybox.Time;
import Toybox.System;
import Toybox.Attention;

class MainView extends WatchUi.View {

    var _timer as Timer.Timer;
    var _alertBlink as Lang.Boolean = false;
    var _buddyEvolved as Lang.Number = 0;
    var _evoShowCount as Lang.Number = 0; // frames restantes para mostrar evo

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onLayout(dc as Graphics.Dc) as Void {}

    function onShow() as Void {
        _timer.start(method(:onTimer), 1500, true);
        GameState.updateTotalSteps();
        GameState.updateActivityBlocks();
        GameState.updateBuddySteps();
        checkSpawn();
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTimer() as Void {
        GameState.updateTotalSteps();
        GameState.updateActivityBlocks();
        GameState.updateBuddySteps();
        var evo = GameState.checkBuddyEvolution();
        if (evo > 0) {
            _buddyEvolved = evo;
            _evoShowCount = 20; // mostrar por ~30s (20 ticks x 1.5s)
            // Vibrar al evolucionar buddy
            try {
                if (Attention has :vibrate) {
                    Attention.vibrate([
                        new Attention.VibeProfile(50, 200),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400)
                    ]);
                }
            } catch (e) {}
        }
        if (_evoShowCount > 0) {
            _evoShowCount -= 1;
            if (_evoShowCount <= 0) {
                _buddyEvolved = 0;
            }
        }
        _alertBlink = !_alertBlink;
        checkSpawn();
        WatchUi.requestUpdate();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    // Devuelve la hora local del sistema (0-23)
    function getLocalHour() as Lang.Number {
        return System.getClockTime().hour;
    }

    function checkSpawn() as Void {
        if (GameState.currentEncounter != null) { return; }

        // Misiones legendarias tienen prioridad
        var legendaryId = LegendaryQuestManager.checkQuests();
        if (legendaryId > 0) {
            GameState.currentEncounter = LegendaryQuestManager.spawnLegendary(legendaryId);
            GameState.registerSeen(legendaryId);
            GameState.save();
            vibrateSpawn();
            WatchUi.requestUpdate();
            return;
        }

        // Spawn normal
        if (GameState.shouldSpawn()) {
            var blocks = GameState.getActivityBlocksToday();
            var spawnSuccessMax = BalanceConfig.getSpawnRollSuccessMaxForBlocks(blocks);
            if ((Math.rand() % BalanceConfig.getSpawnRollDenominator()) < spawnSuccessMax) {
                var encounter = SpawnEngine.generate();
                GameState.registerSeen(encounter[:id]);
                GameState.currentEncounter = encounter;
                GameState.markSpawn();
                vibrateSpawn();
                WatchUi.requestUpdate();
            }
        }
    }

    // Vibrar al aparecer un Pokémon
    function vibrateSpawn() as Void {
        try {
            if (Attention has :vibrate) {
                Attention.vibrate([
                    new Attention.VibeProfile(50, 300),
                    new Attention.VibeProfile(0, 100),
                    new Attention.VibeProfile(50, 300)
                ]);
            }
        } catch (e) {}
    }

    function getTimeColors() as Lang.Array {
        var hour = getLocalHour();
        if (hour >= 6 && hour < 10) {
            return [0x0F0A05, 0xFFAA44, 0x1A1008];
        } else if (hour >= 10 && hour < 17) {
            return [0x050A0F, 0x44CCFF, 0x081218];
        } else if (hour >= 17 && hour < 20) {
            return [0x0F0508, 0xFF7744, 0x180810];
        } else {
            return [0x05050F, 0x6666CC, 0x0A0A18];
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w  = dc.getWidth();
        var cx = w / 2;

        var timeColors = getTimeColors();
        var bgColor = timeColors[0];
        var accentColor = timeColors[1];
        var bgTint = timeColors[2];

        dc.setColor(bgColor, bgColor);
        dc.clear();

        // ── Fondo Game Boy (escenario pixelart) ──────────
        drawGBBackground(dc, w, w);

        var steps  = GameState.getStepsToday();
        var blocks = GameState.getActivityBlocksToday();
        var nextIn = GameState.stepsUntilNext();
        var unique = GameState.uniqueCaught();
        var streak = GameState.dailyStreak;
        var spawnInterval = BalanceConfig.getStepsPerSpawn();

        var hasEncounter = (GameState.currentEncounter != null);
        var hasBuddy = (GameState.buddyId > 0);
        var displayId = 0;
        if (hasEncounter) {
            displayId = GameState.currentEncounter[:id];
        } else if (hasBuddy) {
            displayId = GameState.buddyId;
        }

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var tierColor = accentColor;
        if (displayId > 0) {
            var displayData = PokemonData.get(displayId);
            var displayTier = displayData[:tier];
            tierColor = tierColors[displayTier];
        }

        var titleY   = 5;
        var stepsY   = 50;
        // Box visual compacto (96x96), bitmap 120px centrado dentro
        var boxSize  = 96;
        var boxY     = 80;
        var bmpOff   = (120 - boxSize) / 2; // 12px para centrar bitmap en box
        var spriteDrawY = boxY - bmpOff;     // bitmap empieza 12px antes del box
        var nameY    = boxY + boxSize + 6;   // 182
        var buddyBarY = nameY + 40;          // 204
        var buddyTxtY = buddyBarY + 15;      // 237
        var infoY    = buddyTxtY + 28;       // 265
        var footY    = 320;

        // ── Spawn progress (0-100) ────────────────────────
        var spawnProgress = 0;
        if (spawnInterval > 0 && !hasEncounter) {
            spawnProgress = ((spawnInterval - nextIn) * 100) / spawnInterval;
            if (spawnProgress > 100) { spawnProgress = 100; }
            if (spawnProgress < 0) { spawnProgress = 0; }
        }
        if (hasEncounter) { spawnProgress = 100; }

        // ── ARCO DE SPAWN PROGRESS ───────────────────────
        if (spawnProgress > 0) {
            dc.setPenWidth(3);
            if (hasEncounter) {
                dc.setColor(_alertBlink ? 0xFF4444 : 0xFF8888, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(cx, w / 2, cx - 2);
            } else {
                dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
                if (spawnProgress >= 100) {
                    dc.drawCircle(cx, w / 2, cx - 2);
                } else {
                    var endAngle = 90 - (spawnProgress * 360 / 100);
                    dc.drawArc(cx, w / 2, cx - 2, Graphics.ARC_CLOCKWISE, 90, endAngle);
                }
            }
            dc.setPenWidth(1);
        }

        // ── CABECERA: HORA + PASOS ────────────────────────
        var clk = System.getClockTime();
        var hr = clk.hour;
        var is24h = System.getDeviceSettings().is24Hour;
        if (!is24h) {
            if (hr == 0) { hr = 12; }
            else if (hr > 12) { hr -= 12; }
        }
        var timeStr = hr.format("%d") + ":" + clk.min.format("%02d");
        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_SMALL,
            timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        var stepsStr = steps.toString() + " " + tr(Rez.Strings.LabelSteps);
        if (blocks >= BalanceConfig.getActivityBonusMinBlocks()) {
            stepsStr = stepsStr + " ★";
        }
        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, stepsY, Graphics.FONT_XTINY,
            stepsStr, Graphics.TEXT_JUSTIFY_CENTER);

        // ── SPRITE centrado con recuadro gris ─────────────

        if (displayId > 0) {
            // Recuadro gris compacto (96x96) estilo EncounterView
            var boxX = cx - boxSize / 2;
            dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(boxX, boxY, boxSize, boxSize, 10);
            dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
            dc.drawRoundedRectangle(boxX, boxY, boxSize, boxSize, 10);

            // Bobbing dinámico (±4px)
            var mainBob = _alertBlink ? -4 : 4;
            var displaySprite = SpriteManager.getSprite(displayId);
            if (displaySprite != null) {
                // Bitmap 120px centrado dentro del box de 96px
                dc.drawBitmap(cx - 60, spriteDrawY + mainBob, displaySprite as WatchUi.BitmapResource);
            } else {
                dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, boxY + 30, Graphics.FONT_NUMBER_THAI_HOT,
                    "#" + displayId.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);
            }

            // ── NOMBRE + NIVEL ─────────────────────────────────
            var nameColor = tierColor;
            if (hasEncounter) { nameColor = 0xFF6666; }
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            var displayName = PokemonData.getName(displayId).toUpper();
            if (!hasEncounter && hasBuddy) {
                var buddyLevel = GameState.getPokemonLevel(displayId);
                displayName = displayName + " Lv." + buddyLevel.toString();
            }
            dc.drawText(cx, nameY, Graphics.FONT_XTINY,
                displayName,
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Sin buddy: mostrar texto invitando a elegir
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, boxY + 30, Graphics.FONT_XTINY,
                "?", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, nameY, Graphics.FONT_XTINY,
                tr(Rez.Strings.BuddyHint), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // (spawn bar removida — el info text ya muestra progreso)

        // ── BUDDY LEVEL BAR + STEPS INFO ──────────────
        if (!hasEncounter && hasBuddy) {
            var currentLevel = GameState.getPokemonLevel(displayId);
            var currentXP = GameState.getPokemonXP(displayId);
            var buddyData2 = PokemonData.get(displayId);
            var buddyTier2 = buddyData2[:tier];
            var nextLevelXP = BalanceConfig.getXPForLevel(currentLevel + 1, buddyTier2);
            var stepsToNext = nextLevelXP - currentXP;
            if (stepsToNext < 0) { stepsToNext = 0; }
            var levelXPBase = BalanceConfig.getXPForLevel(currentLevel, buddyTier2);
            var xpInLevel = currentXP - levelXPBase;
            var xpNeeded = nextLevelXP - levelXPBase;
            var progress = 0;
            if (xpNeeded > 0) { progress = (xpInLevel * 100) / xpNeeded; }
            if (progress > 100) { progress = 100; }
            if (currentLevel >= 100) { progress = 100; stepsToNext = 0; }

            // Barra de nivel
            var barW = 100;
            var barX = cx - barW / 2;
            var fillW = (progress * barW) / 100;
            dc.setColor(0x151515, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, buddyBarY, barW, 5, 2);
            if (fillW > 0) {
                var barColor = 0x44CCFF;
                if (progress > 75) { barColor = 0x44FF44; }
                if (progress > 90) { barColor = 0xFFCC00; }
                dc.setColor(barColor, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(barX, buddyBarY, fillW, 5, 2);
            }

            // Texto: pasos restantes para subir de nivel
            dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
            if (currentLevel >= 100) {
                dc.drawText(cx, buddyTxtY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.LevelMax), Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(cx, buddyTxtY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.LevelUpPrefix) + stepsToNext.toString() + " p.",
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else if (!hasEncounter && !hasBuddy) {
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, buddyTxtY, Graphics.FONT_XTINY,
                tr(Rez.Strings.SelectBuddy), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // ── INFO / ENCOUNTER / EVO NOTIFICATION ──────────
        if (hasEncounter) {
            var isLegQuest = LegendaryQuestManager.isQuestLegendary(displayId);
            if (isLegQuest) {
                dc.setColor(0x2A1A00, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(cx - 85, infoY - 2, 170, 40, 6);
                dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.QuestLegendary),
                    Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(cx, infoY + 18, Graphics.FONT_XTINY,
                    tr(Rez.Strings.TapToEnter),
                    Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0x2A0808, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(cx - 85, infoY - 2, 170, 40, 6);
                dc.setColor(0xFF5555, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.EncounterReady),
                    Graphics.TEXT_JUSTIFY_CENTER);
                dc.drawText(cx, infoY + 18, Graphics.FONT_XTINY,
                    tr(Rez.Strings.TapToEnter),
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.setColor(bgTint, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(cx - 85, infoY - 2, 170, 24, 6);
            if (_buddyEvolved > 0) {
                var evoName = PokemonData.getName(_buddyEvolved).toUpper();
                dc.setColor(0xFFD700, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.BuddyEvolved) + " -> " + evoName,
                    Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.NextIn) + " " + nextIn.toString() + " " + tr(Rez.Strings.LabelSteps),
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // ── PIE: DEX, BATERÍA y RACHA ────────────────────
        dc.setColor(bgTint, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(60, footY - 4, w - 120, 26, 8);
        dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 70, footY, Graphics.FONT_XTINY,
            unique.toString() + "/" + PokemonData.TOTAL_POKEMON.toString(), Graphics.TEXT_JUSTIFY_CENTER);
        var batt = System.getSystemStats().battery.toNumber();
        var battColor = 0x44CC44;
        if (batt < 30) { battColor = 0xFF8800; }
        if (batt < 15) { battColor = 0xFF4444; }
        dc.setColor(battColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, footY, Graphics.FONT_XTINY,
            batt.toString() + "%", Graphics.TEXT_JUSTIFY_CENTER);
        var streakColor = 0x888888;
        if (streak >= 3) { streakColor = 0xFF8800; }
        if (streak >= 7) { streakColor = 0xFF4400; }
        if (streak >= 14) { streakColor = 0xFF0000; }
        dc.setColor(streakColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 80, footY, Graphics.FONT_XTINY,
            streak.toString() + tr(Rez.Strings.LabelStreakDays),
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    // ── Dibujar fondo estilo Game Boy (bitmap) ─────────────────
    function drawGBBackground(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var hour = getLocalHour();

        var bgRes = null;
        if (hour >= 6 && hour < 10) {
            bgRes = Rez.Drawables.bg_route_morning;
        } else if (hour >= 10 && hour < 17) {
            bgRes = Rez.Drawables.bg_route_day;
        } else if (hour >= 17 && hour < 20) {
            bgRes = Rez.Drawables.bg_route_sunset;
        } else {
            bgRes = Rez.Drawables.bg_route_night;
        }

        try {
            var bg = WatchUi.loadResource(bgRes) as WatchUi.BitmapResource;
            dc.drawBitmap(0, 0, bg);
        } catch (e) {
            // fallback: fondo negro si no se puede cargar
        }
    }

}

class MainDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Lang.Boolean {
        if (GameState.currentEncounter != null) {
            var v = new EncounterView();
            WatchUi.pushView(v, new EncounterDelegate(v), WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }

    function onNextPage() as Lang.Boolean {
        var v = new PokedexView();
        WatchUi.pushView(v, new PokedexDelegate(v), WatchUi.SLIDE_UP);
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
