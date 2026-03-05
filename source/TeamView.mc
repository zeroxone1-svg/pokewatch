// ============================================================
//  TeamView.mc — Vista del equipo de 6 Pokémon
//  Muestra los 6 slots (buddy + team), niveles, avg level.
//  Tap en un slot para quitarlo del equipo.
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class TeamView extends WatchUi.View {

    var _flashMsg as Lang.String = "";
    var _flashFrames as Lang.Number = 0;

    function initialize() {
        View.initialize();
    }

    // Build effective team: buddy as slot 1 + team members (up to 6 total)
    function getEffectiveTeam() as Lang.Array {
        var ids = [] as Lang.Array;
        if (GameState.buddyId > 0) {
            ids.add(GameState.buddyId);
        }
        for (var i = 0; i < GameState.team.size(); i++) {
            if (GameState.team[i] != GameState.buddyId && ids.size() < 6) {
                ids.add(GameState.team[i]);
            }
        }
        return ids;
    }

    function getIdAtTapY(tapY as Lang.Number) as Lang.Number {
        var startY = Layout.Team.LIST_START_Y;
        var slotH = Layout.Team.SLOT_H;
        if (tapY < startY || tapY >= startY + 6 * slotH) {
            return 0;
        }
        var row = (tapY - startY) / slotH;
        var team = getEffectiveTeam();
        if (row < team.size()) {
            return team[row] as Lang.Number;
        }
        return 0;
    }

    function showFlash(msg as Lang.String) as Void {
        _flashMsg = msg;
        _flashFrames = 3;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var cx = w / 2;

        dc.setColor(0x050508, 0x050508);
        dc.clear();

        // Header
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(90, Layout.Team.HEADER_Y, w - 180, Layout.Team.HEADER_H, 8);
        dc.setColor(0x44CCFF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Team.TITLE_Y, Graphics.FONT_XTINY,
            "TEAM", Graphics.TEXT_JUSTIFY_CENTER);

        // Avg level + team count
        var team = getEffectiveTeam();
        var avgLv = GameState.getTeamAvgLevel();
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Team.STATS_Y, Graphics.FONT_XTINY,
            team.size().toString() + "/6  Avg Lv." + avgLv.toString(),
            Graphics.TEXT_JUSTIFY_CENTER);

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var slotH = Layout.Team.SLOT_H;
        var startY = Layout.Team.LIST_START_Y;

        for (var i = 0; i < 6; i++) {
            var y = startY + (i * slotH);
            var textY = y + 10;

            // Alternating backgrounds
            if (i % 2 == 0) {
                dc.setColor(0x0A0A12, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(30, y, w - 60, slotH);
            }

            if (i < team.size()) {
                var id = team[i] as Lang.Number;
                var data = PokemonData.get(id);
                var tier = data[:tier];
                var level = GameState.getPokemonLevel(id);
                var isBuddy = (id == GameState.buddyId);
                var isShiny = GameState.shinyList.indexOf(id) != -1;

                // Slot number
                var slotColor = isBuddy ? 0x44CC44 : 0x4488FF;
                dc.setColor(slotColor, Graphics.COLOR_TRANSPARENT);
                dc.drawText(Layout.Team.SLOT_NUM_X, textY, Graphics.FONT_XTINY,
                    (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);

                // Buddy/Team marker
                if (isBuddy) {
                    dc.setColor(0x0A1A0A, Graphics.COLOR_TRANSPARENT);
                    dc.fillRectangle(30, y, w - 60, slotH);
                    dc.setColor(0x44CC44, Graphics.COLOR_TRANSPARENT);
                    dc.drawRectangle(30, y, w - 60, slotH);
                }

                // Name
                var name = PokemonData.getName(id);
                if (isShiny) { name = "★" + name; }
                dc.setColor(tierColors[tier], Graphics.COLOR_TRANSPARENT);
                dc.drawText(Layout.Team.NAME_X, textY, Graphics.FONT_XTINY,
                    name, Graphics.TEXT_JUSTIFY_LEFT);

                // Level on the right
                dc.setColor(0xBBBBBB, Graphics.COLOR_TRANSPARENT);
                dc.drawText(w - Layout.Team.LEVEL_X_PAD, textY, Graphics.FONT_XTINY,
                    "Lv." + level.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
            } else {
                // Empty slot
                dc.setColor(0x222222, Graphics.COLOR_TRANSPARENT);
                dc.drawText(Layout.Team.SLOT_NUM_X, textY, Graphics.FONT_XTINY,
                    (i + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);
                dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, textY, Graphics.FONT_XTINY,
                    "- empty -", Graphics.TEXT_JUSTIFY_CENTER);
            }

            // Separator
            dc.setColor(0x111118, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(40, y + slotH - 1, w - 40, y + slotH - 1);
        }

        // Flash message
        if (_flashFrames > 0) {
            dc.setColor(0x1A1A2A, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(cx - 80, Layout.Team.FOOTER_Y, 160, Layout.Team.FOOTER_H, 6);
            dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, Layout.Team.FOOTER_Y + 2, Graphics.FONT_XTINY,
                _flashMsg, Graphics.TEXT_JUSTIFY_CENTER);
            _flashFrames -= 1;
        } else {
            // Footer hint
            dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(80, Layout.Team.FOOTER_Y, w - 160, Layout.Team.FOOTER_H, 6);
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, Layout.Team.FOOTER_Y + 2, Graphics.FONT_XTINY,
                "Tap to remove", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

class TeamDelegate extends WatchUi.BehaviorDelegate {
    var _view as TeamView;

    function initialize(view as TeamView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        var coords = evt.getCoordinates();
        var tapY = coords[1] as Lang.Number;
        var pickId = _view.getIdAtTapY(tapY);
        if (pickId > 0) {
            if (pickId == GameState.buddyId) {
                _view.showFlash("Buddy can't be removed");
            } else {
                GameState.removeFromTeam(pickId);
                _view.showFlash("Removed!");
            }
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onBack() as Lang.Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
