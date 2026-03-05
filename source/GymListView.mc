// ============================================================
//  GymListView.mc — Lista de 20 gimnasios con estado
//  Kanto (8) + Johto (8) + Elite Four (4)
//  Cursor-based selection, swipe right to challenge
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;

class GymListView extends WatchUi.View {

    var _cursor as Lang.Number = 0;
    var _scroll as Lang.Number = 0;
    const VISIBLE_ROWS = 3;
    const LINE_H = 50;
    const START_Y = 90;

    function initialize() {
        View.initialize();
    }

    function ensureCursorVisible() as Void {
        if (_cursor < _scroll) {
            _scroll = _cursor;
        } else if (_cursor >= _scroll + VISIBLE_ROWS) {
            _scroll = _cursor - VISIBLE_ROWS + 1;
        }
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(0x050508, 0x050508);
        dc.clear();

        // Header
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(60, Layout.Gym.HEADER_BG_Y, w - 120, Layout.Gym.HEADER_BG_H, 8);
        dc.setColor(0xBB66FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Gym.TITLE_Y, Graphics.FONT_XTINY,
            "GYMS & ELITE FOUR", Graphics.TEXT_JUSTIFY_CENTER);

        // Stats
        var badges = GameState.getGymBadgeCount();
        var wins = GameState.rivalWins;
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Gym.STATS_Y, Graphics.FONT_XTINY,
            badges.toString() + "/20 medals  " + wins.toString() + " wins",
            Graphics.TEXT_JUSTIFY_CENTER);

        for (var i = 0; i < VISIBLE_ROWS; i++) {
            var idx = _scroll + i;
            if (idx >= BalanceConfig.GYM_COUNT) { break; }

            var gymData = BalanceConfig.GYM_DATA[idx];
            var name = gymData[0];
            var pokId = gymData[1];
            var level = gymData[2];
            var status = GameState.getGymStatus(idx);
            var y = Layout.Gym.LIST_START_Y + (i * Layout.Gym.LINE_H);
            var isSelected = (idx == _cursor);

            // Region color coding
            var regionColor = 0x4488FF; // Kanto blue
            if (idx >= 8 && idx < 16) { regionColor = 0xFF66FF; } // Johto pink
            if (idx >= 16) { regionColor = 0xFFAA00; } // Elite Four gold

            // Row background
            if (isSelected) {
                dc.setColor(0x181830, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(Layout.Gym.ROW_PAD, y, w - Layout.Gym.ROW_PAD * 2, Layout.Gym.LINE_H - 2, 8);
                // Selection border
                var selColor = 0x4488FF;
                if (status == 2) { selColor = 0x44CC44; }
                else if (status == 1) { selColor = regionColor; }
                dc.setColor(selColor, Graphics.COLOR_TRANSPARENT);
                dc.drawRoundedRectangle(Layout.Gym.ROW_PAD, y, w - Layout.Gym.ROW_PAD * 2, Layout.Gym.LINE_H - 2, 8);
            } else if (i % 2 == 0) {
                dc.setColor(0x0A0A12, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(Layout.Gym.ROW_PAD, y, w - Layout.Gym.ROW_PAD * 2, Layout.Gym.LINE_H - 2, 6);
            }

            if (status == 2 && !isSelected) {
                dc.setColor(0x0A1A0A, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(Layout.Gym.ROW_PAD, y, w - Layout.Gym.ROW_PAD * 2, Layout.Gym.LINE_H - 2, 6);
            }

            // Selection arrow
            if (isSelected) {
                dc.setColor(0xDDDDDD, Graphics.COLOR_TRANSPARENT);
                dc.drawText(Layout.Gym.ARROW_X, y + 14, Graphics.FONT_XTINY,
                    ">", Graphics.TEXT_JUSTIFY_LEFT);
            }

            // Badge number
            var numColor = 0x444444;
            if (status == 2) { numColor = 0x44CC44; }
            else if (status == 1) { numColor = regionColor; }
            if (isSelected) { numColor = 0xFFFFFF; }
            dc.setColor(numColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.Gym.NUM_X, y + 4, Graphics.FONT_XTINY,
                (idx + 1).format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

            // Gym leader name
            var nameColor = 0x383838;
            if (status == 1) { nameColor = 0xDDDDDD; }
            if (status == 2) { nameColor = 0x88FF88; }
            if (isSelected && status == 0) { nameColor = 0x888888; }
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.Gym.NAME_X, y + 4, Graphics.FONT_XTINY,
                name, Graphics.TEXT_JUSTIFY_LEFT);

            // Pokemon name + level (second line)
            var pokName = PokemonData.getName(pokId);
            var infoColor = 0x444444;
            if (isSelected) { infoColor = 0x666666; }
            dc.setColor(infoColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.Gym.NAME_X, y + 24, Graphics.FONT_XTINY,
                pokName + " Lv." + level.toString(),
                Graphics.TEXT_JUSTIFY_LEFT);

            // Status label
            var statusStr = "LOCKED";
            var statusColor = 0x333333;
            if (status == 1) { statusStr = "GO!"; statusColor = regionColor; }
            if (status == 2) { statusStr = "WON"; statusColor = 0x44CC44; }
            if (isSelected && status == 0) { statusColor = 0x555555; }
            dc.setColor(statusColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - Layout.Gym.STATUS_X_PAD, y + 14, Graphics.FONT_XTINY,
                statusStr, Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Footer
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(50, h - Layout.Gym.FOOTER_PAD, w - 100, 24, 8);
        dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h - Layout.Gym.FOOTER_PAD + 2, Graphics.FONT_XTINY,
            (_cursor + 1).toString() + "/" + BalanceConfig.GYM_COUNT.toString() + "  swipe \u2192 battle",
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class GymListDelegate extends WatchUi.BehaviorDelegate {
    var _view as GymListView;

    function initialize(view as GymListView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Lang.Boolean {
        if (_view._cursor < BalanceConfig.GYM_COUNT - 1) {
            _view._cursor++;
            _view.ensureCursorVisible();
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        if (_view._cursor > 0) {
            _view._cursor--;
            _view.ensureCursorVisible();
            WatchUi.requestUpdate();
        }
        return true;
    }

    function startGymBattle() as Lang.Boolean {
        var gymIdx = _view._cursor;
        var status = GameState.getGymStatus(gymIdx);
        if (status == 1 && GameState.currentBattle == null) {
            var gymData = BalanceConfig.GYM_DATA[gymIdx];
            var rivalId = gymData[1];
            var rivalLevel = gymData[2];
            var baseSteps = gymData[3];
            var timeLimitSec = gymData[4];
            var xpReward = gymData[6];

            var avgLevel = GameState.getTeamAvgLevel();
            var requiredSteps = baseSteps * rivalLevel / avgLevel;
            if (requiredSteps < 100) { requiredSteps = 100; }

            GameState.startBattle(rivalId, rivalLevel, requiredSteps,
                timeLimitSec, gymIdx, xpReward);

            var v = new BattleView();
            WatchUi.pushView(v, new BattleDelegate(v), WatchUi.SLIDE_LEFT);
            return true;
        }
        return false;
    }

    function onSwipe(evt as WatchUi.SwipeEvent) as Lang.Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_RIGHT) {
            return startGymBattle();
        }
        return false;
    }

    function onSelect() as Lang.Boolean {
        return startGymBattle();
    }

    function onBack() as Lang.Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
