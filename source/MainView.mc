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
        _timer.start(method(:onTimer), 5000, true);
        GameState.updateActivityBlocks();
        GameState.updateBuddySteps();
        GameState.updateTotalSteps();
        checkSpawn();
    }

    function onHide() as Void {
        _timer.stop();
    }

    function onTimer() as Void {
        GameState.updateActivityBlocks();
        GameState.updateBuddySteps();
        GameState.updateTotalSteps();
        var evo = GameState.checkBuddyEvolution();
        if (evo > 0) {
            _buddyEvolved = evo;
            _evoShowCount = 6; // mostrar por ~30s (6 ticks x 5s)
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

    function checkSpawn() as Void {
        if (GameState.currentEncounter != null) { return; }

        // Misiones legendarias tienen prioridad
        var legendaryId = LegendaryQuestManager.checkQuests();
        if (legendaryId > 0) {
            GameState.currentEncounter = LegendaryQuestManager.spawnLegendary(legendaryId);
            GameState.registerSeen(legendaryId);
            GameState.save();
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
                WatchUi.requestUpdate();
            }
        }
    }

    function getTimeColors() as Lang.Array {
        var now = Time.now();
        var info = Time.Gregorian.info(now, Time.FORMAT_SHORT);
        var hour = info.hour;
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

        var titleY   = 28;
        var stepsY   = 52;
        var spriteY  = 80;
        var spriteH  = 80;
        var nameY    = spriteY + spriteH + 4;
        var buddyBarY = nameY + 30;
        var buddyTxtY = buddyBarY + 5;
        var infoY    = buddyTxtY + 26;
        var footY    = 300;

        // ── Spawn progress (0-100) ────────────────────────
        var spawnProgress = 0;
        if (spawnInterval > 0 && !hasEncounter) {
            spawnProgress = ((spawnInterval - nextIn) * 100) / spawnInterval;
            if (spawnProgress > 100) { spawnProgress = 100; }
            if (spawnProgress < 0) { spawnProgress = 0; }
        }
        if (hasEncounter) { spawnProgress = 100; }

        // ── CABECERA ──────────────────────────────────────
        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_XTINY,
            "POKEWATCH", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, stepsY, Graphics.FONT_XTINY,
            steps.toString() + " " + tr(Rez.Strings.LabelSteps),
            Graphics.TEXT_JUSTIFY_CENTER);

        // ── SPRITE centrado (sin fondo detrás) ─────────────

        if (displayId > 0) {
            // Bobbing sutil en el sprite
            var mainBob = _alertBlink ? -2 : 2;
            var displaySprite = SpriteManager.getSprite(displayId);
            if (displaySprite != null) {
                dc.drawBitmap(cx - spriteH / 2, spriteY + mainBob, displaySprite as WatchUi.BitmapResource);
            } else {
                dc.setColor(tierColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, spriteY + 34, Graphics.FONT_NUMBER_THAI_HOT,
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
            dc.drawText(cx, spriteY + 30, Graphics.FONT_XTINY,
                "?", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, nameY, Graphics.FONT_XTINY,
                tr(Rez.Strings.BuddyHint), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // (spawn bar removida — el info text ya muestra progreso)

        // ── BUDDY EVOLUTION BAR + LEVEL INFO ─────────────
        if (!hasEncounter && hasBuddy) {
            var buddyData = PokemonData.get(displayId);
            var evoLevel = GameState.getBuddyEvoLevel();
            var evoCost = BalanceConfig.getEffectiveEvolutionCost(buddyData[:evoCost]);
            var caughtN = GameState.getCaughtCount(displayId);
            var currentLevel = GameState.getPokemonLevel(displayId);

            if (evoLevel > 0 || evoCost > 0) {
                // Barra de evolución por nivel
                if (evoLevel > 0) {
                    var progress = GameState.getBuddyProgress();
                    var barW = 100;
                    var barX = cx - barW / 2;
                    var fillW = (progress * barW) / 100;
                    dc.setColor(0x151515, Graphics.COLOR_TRANSPARENT);
                    dc.fillRoundedRectangle(barX, buddyBarY, barW, 5, 2);
                    if (fillW > 0) {
                        var evoColor = 0x44CCFF;
                        if (progress > 75) { evoColor = 0x44FF44; }
                        if (progress > 90) { evoColor = 0xFFCC00; }
                        dc.setColor(evoColor, Graphics.COLOR_TRANSPARENT);
                        dc.fillRoundedRectangle(barX, buddyBarY, fillW, 5, 2);
                    }
                }
                // Texto: nivel → nivel evo + capturas
                var infoTxt = "";
                if (evoLevel > 0) {
                    infoTxt = "Lv." + currentLevel.toString() + "/" + evoLevel.toString();
                }
                if (evoCost > 0) {
                    if (infoTxt.length() > 0) { infoTxt = infoTxt + "  "; }
                    infoTxt = infoTxt + caughtN.toString() + "/" + evoCost.toString() + "x";
                }
                dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, buddyTxtY, Graphics.FONT_XTINY,
                    infoTxt, Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, buddyTxtY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.BuddyMaxForm), Graphics.TEXT_JUSTIFY_CENTER);
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
                dc.fillRoundedRectangle(cx - 85, infoY - 2, 170, 24, 6);
                dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.QuestLegendary) + " - " + tr(Rez.Strings.TapToEnter),
                    Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0x2A0808, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(cx - 85, infoY - 2, 170, 24, 6);
                dc.setColor(0xFF5555, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, infoY, Graphics.FONT_XTINY,
                    tr(Rez.Strings.EncounterReady) + " - " + tr(Rez.Strings.TapToEnter),
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

        // ── PIE: DEX y RACHA ─────────────────────────────
        dc.setColor(bgTint, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(60, footY - 4, w - 120, 26, 8);
        dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - 50, footY, Graphics.FONT_XTINY,
            unique.toString() + "/151", Graphics.TEXT_JUSTIFY_CENTER);
        var streakColor = 0x888888;
        if (streak >= 3) { streakColor = 0xFF8800; }
        if (streak >= 7) { streakColor = 0xFF4400; }
        if (streak >= 14) { streakColor = 0xFF0000; }
        dc.setColor(streakColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + 50, footY, Graphics.FONT_XTINY,
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
