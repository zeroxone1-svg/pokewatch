// ============================================================
//  BattleView.mc — Pantalla de batalla contra entrenadores/gyms
//
//  Mecánica: Pasos vs Tiempo
//    - HP del rival baja con tus pasos
//    - Tu HP baja con el tiempo
//    - Victoria si rival llega a 0 HP antes del tiempo límite
//    - Derrota si el tiempo se acaba primero
//    - Funciona en background (estado persiste en Storage)
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.System;
import Toybox.Time;

class BattleView extends WatchUi.View {

    var _timer as Timer.Timer;
    var _result as Lang.Number = 0;  // 0=in progress, 1=victory, 2=defeat
    var _animFrame as Lang.Number = 0;
    var _shouldPop as Lang.Boolean = false;

    function initialize() {
        View.initialize();
        _timer = new Timer.Timer();
    }

    function onShow() as Void {
        _timer.start(method(:onTimer), 1500, true);
        // Check if battle already resolved
        if (GameState.currentBattle != null) {
            _result = GameState.checkBattleResult();
            if (_result != 0) {
                var victory = (_result == 1);
                GameState.finishBattle(victory);
                vibrateBattleEnd(victory);
            }
        } else {
            _shouldPop = true;
        }
    }

    function onHide() as Void {
        _timer.stop();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function onTimer() as Void {
        if (_shouldPop) {
            _shouldPop = false;
            _timer.stop();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }

        _animFrame = (_animFrame + 1) % 4;

        if (_result == 0 && GameState.currentBattle != null) {
            GameState.updateTotalSteps();
            _result = GameState.checkBattleResult();
            if (_result != 0) {
                var victory = (_result == 1);
                GameState.finishBattle(victory);
                vibrateBattleEnd(victory);
            }
        }
        WatchUi.requestUpdate();
    }

    function vibrateBattleEnd(victory as Lang.Boolean) as Void {
        try {
            if (Attention has :vibrate) {
                if (victory) {
                    Attention.vibrate([
                        new Attention.VibeProfile(50, 200),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400),
                        new Attention.VibeProfile(0, 100),
                        new Attention.VibeProfile(80, 400)
                    ]);
                } else {
                    Attention.vibrate([
                        new Attention.VibeProfile(80, 600)
                    ]);
                }
            }
        } catch (e) {}
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Battle background
        drawBattleBackground(dc, w, h);

        // Clock
        drawClock(dc, w);

        // Result screen
        if (_result != 0) {
            drawResultScreen(dc, w, h);
            return;
        }

        // No battle active — pop back
        if (GameState.currentBattle == null) {
            _shouldPop = true;
            return;
        }

        var battle = GameState.currentBattle;
        var rivalId = battle[:rivalId];
        var rivalLevel = battle[:rivalLevel];
        var requiredSteps = battle[:requiredSteps];
        var timeLimitSec = battle[:timeLimitSec];
        var battleType = battle[:battleType];

        var stepsWalked = GameState.getBattleStepsWalked();
        var timeElapsed = GameState.getBattleTimeElapsed();

        // Rival HP % (decreases with steps)
        var rivalHpPct = 100 - (stepsWalked * 100 / requiredSteps);
        if (rivalHpPct < 0) { rivalHpPct = 0; }
        // Your HP % (decreases with time)
        var yourHpPct = 100 - (timeElapsed * 100 / timeLimitSec);
        if (yourHpPct < 0) { yourHpPct = 0; }

        var timeRemaining = timeLimitSec - timeElapsed;
        if (timeRemaining < 0) { timeRemaining = 0; }
        var minLeft = timeRemaining / 60;
        var secLeft = timeRemaining % 60;

        // Trainer label
        var trainerLabel = "TRAINER";
        if (battleType == -2) {
            trainerLabel = "ACE TRAINER";
        } else if (battleType >= 0 && battleType < BalanceConfig.GYM_COUNT) {
            var gymData = BalanceConfig.GYM_DATA[battleType];
            trainerLabel = gymData[0];
        }

        // Header — trainer name
        dc.setColor(0xBB66FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Battle.TRAINER_NAME_Y, Graphics.FONT_XTINY,
            trainerLabel, Graphics.TEXT_JUSTIFY_CENTER);

        // Rival sprite
        var bobOffsets = [0, -2, 0, 2];
        var bob = bobOffsets[_animFrame];
        var ss = Layout.Battle.SPRITE_SIZE;
        var halfSS = ss / 2;
        dc.setColor(0x1A1A1A, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - halfSS, Layout.Battle.SPRITE_Y, ss, ss, Layout.Battle.SPRITE_RADIUS);
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(cx - halfSS, Layout.Battle.SPRITE_Y, ss, ss, Layout.Battle.SPRITE_RADIUS);
        var sprite = SpriteManager.getSprite(rivalId);
        if (sprite != null) {
            dc.drawBitmap(cx - halfSS, Layout.Battle.SPRITE_Y + bob, sprite as WatchUi.BitmapResource);
        }

        // Rival name + level
        var rivalName = PokemonData.getName(rivalId).toUpper();
        dc.setColor(0xFF6666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Battle.RIVAL_NAME_Y, Graphics.FONT_XTINY,
            rivalName + " Lv." + rivalLevel.toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        // Rival HP bar (steps)
        var barW = Layout.Battle.BAR_WIDTH;
        var barX = cx - barW / 2;
        var barH = Layout.Battle.BAR_HEIGHT;
        var barR = Layout.Battle.BAR_RADIUS;
        var rivalFillW = (rivalHpPct * barW) / 100;
        var rivalHpColor = 0x44CC44;
        if (rivalHpPct < 50) { rivalHpColor = 0xFFCC00; }
        if (rivalHpPct < 25) { rivalHpColor = 0xFF4444; }

        dc.setColor(0x262626, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, Layout.Battle.RIVAL_BAR_Y, barW, barH, barR);
        if (rivalFillW > 0) {
            dc.setColor(rivalHpColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, Layout.Battle.RIVAL_BAR_Y, rivalFillW, barH, barR);
        }
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Battle.STEPS_TEXT_Y, Graphics.FONT_XTINY,
            stepsWalked.toString() + "/" + requiredSteps.toString() + " pasos",
            Graphics.TEXT_JUSTIFY_CENTER);

        // Buddy name + team level (like rival label)
        if (GameState.buddyId > 0) {
            var buddyName = PokemonData.getName(GameState.buddyId).toUpper();
            dc.setColor(0x66BBFF, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, Layout.Battle.TEAM_LABEL_Y, Graphics.FONT_XTINY,
                buddyName + " Lv." + GameState.getTeamAvgLevel().toString(),
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Your HP bar (time)
        var yourFillW = (yourHpPct * barW) / 100;
        var yourHpColor = 0x4488FF;
        if (yourHpPct < 50) { yourHpColor = 0xFFCC00; }
        if (yourHpPct < 25) { yourHpColor = 0xFF4444; }

        dc.setColor(0x262626, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, Layout.Battle.TEAM_BAR_Y, barW, barH, barR);
        if (yourFillW > 0) {
            dc.setColor(yourHpColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, Layout.Battle.TEAM_BAR_Y, yourFillW, barH, barR);
        }
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Battle.TIME_TEXT_Y, Graphics.FONT_XTINY,
            minLeft.toString() + ":" + secLeft.format("%02d") + " restante",
            Graphics.TEXT_JUSTIFY_CENTER);

        // Buddy sprite (mirrored horizontally)
        if (GameState.buddyId > 0) {
            var buddySprite = SpriteManager.getSprite(GameState.buddyId);
            if (buddySprite != null) {
                var bmpRef = buddySprite as WatchUi.BitmapResource;
                var bufRef = Graphics.createBufferedBitmap({:width => 120, :height => 120});
                var buf = bufRef.get() as Graphics.BufferedBitmap;
                var bufDc = buf.getDc();
                bufDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_TRANSPARENT);
                bufDc.clear();
                bufDc.drawBitmap(0, 0, bmpRef);
                var mirrorTransform = new Graphics.AffineTransform();
                mirrorTransform.setMatrix([-1.0, 0.0, 120.0, 0.0, 1.0, 0.0]);
                dc.drawBitmap2(cx - Layout.Battle.BUDDY_OFFSET_X, Layout.Battle.BUDDY_Y + bob, buf, {:transform => mirrorTransform});
            }
        }
    }

    function drawResultScreen(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        var cx = w / 2;
        var cy = h / 2;

        if (_result == 1) {
            dc.setColor(0x002200, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, 100);
            dc.setColor(0x44FF44, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 30, Graphics.FONT_SMALL,
                "VICTORIA!", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 10, Graphics.FONT_XTINY,
                "Victorias: " + GameState.rivalWins.toString(),
                Graphics.TEXT_JUSTIFY_CENTER);
            // Show badge info if gym battle
            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 34, Graphics.FONT_XTINY,
                "Medallas: " + GameState.getGymBadgeCount().toString() + "/20",
                Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.setColor(0x220000, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(cx, cy, 100);
            dc.setColor(0xFF4444, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - 30, Graphics.FONT_SMALL,
                "DERROTA", Graphics.TEXT_JUSTIFY_CENTER);
            dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 10, Graphics.FONT_XTINY,
                "Se acabo el tiempo",
                Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h - 52, Graphics.FONT_XTINY,
            "Tap para continuar",
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawClock(dc as Graphics.Dc, w as Lang.Number) as Void {
        var clk = System.getClockTime();
        var hr = clk.hour;
        var is24h = System.getDeviceSettings().is24Hour;
        if (!is24h) {
            if (hr == 0) { hr = 12; }
            else if (hr > 12) { hr -= 12; }
        }
        var timeStr = hr.format("%d") + ":" + clk.min.format("%02d");
        var cx = w / 2;
        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Battle.CLOCK_Y, Graphics.FONT_XTINY, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawBattleBackground(dc as Graphics.Dc, w as Lang.Number, h as Lang.Number) as Void {
        try {
            var bg = WatchUi.loadResource(Rez.Drawables.bg_battle) as WatchUi.BitmapResource;
            dc.drawBitmap(0, 0, bg);
        } catch (e) {}
    }
}

class BattleDelegate extends WatchUi.BehaviorDelegate {
    var _view as BattleView;

    function initialize(view as BattleView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onSelect() as Lang.Boolean {
        if (_view._result != 0) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        return false;
    }

    function onBack() as Lang.Boolean {
        // Swipe back = flee (abandon battle without penalty)
        if (_view._result == 0 && GameState.currentBattle != null) {
            GameState.finishBattle(false);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
