// ============================================================
//  PokedexView.mc — Lista de los 151 Pokémon con estado.
//  ProfileView.mc — Estadísticas del jugador.
//  Rediseñado con mejor estética + buddy selection.
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

// ============================================================
//  POKÉDEX VIEW — Diseño mejorado
// ============================================================
class PokedexView extends WatchUi.View {

    var _scroll as Lang.Number = 0;
    var _flashMsg as Lang.String = "";
    var _flashFrames as Lang.Number = 0;

    function initialize() {
        View.initialize();
    }

    function showFlash(msg as Lang.String) as Void {
        _flashMsg = msg;
        _flashFrames = 3;
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    // Dado un tap en coordenada Y, devolver el id del Pokémon en esa fila.
    // Retorna 0 si no corresponde a ninguna fila válida o no está capturado.
    function getIdAtTapY(tapY as Lang.Number) as Lang.Number {
        var startY = Layout.Pokedex.LIST_START_Y;
        var lineH  = Layout.Pokedex.LINE_H;
        if (tapY < startY || tapY >= startY + Layout.Pokedex.VISIBLE_ROWS * lineH) {
            return 0;
        }
        var row = (tapY - startY) / lineH;
        var idx = _scroll + row;
        if (idx < 0 || idx >= PokemonData.TOTAL_POKEMON) { return 0; }
        var id = idx + 1;
        if (GameState.getCaughtCount(id) > 0) {
            return id;
        }
        return 0;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var cx = w / 2;

        dc.setColor(0x050508, 0x050508);
        dc.clear();

        // Header con fondo (ajustado para pantalla redonda)
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(100, Layout.Pokedex.HEADER_Y, w - 200, Layout.Pokedex.HEADER_H, 8);

        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Pokedex.TITLE_Y, Graphics.FONT_XTINY,
            tr(Rez.Strings.KantoTitle), Graphics.TEXT_JUSTIFY_CENTER);

        // Stats: vistos / capturados / shinies
        var unique = GameState.uniqueCaught();
        var seen = GameState.pokedexSeen.size();
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Pokedex.STATS_Y, Graphics.FONT_XTINY,
            seen.toString() + "v | " +
            unique.toString() + "c | " +
            GameState.shinyList.size().toString() + "sh",
            Graphics.TEXT_JUSTIFY_CENTER);

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var lineH  = Layout.Pokedex.LINE_H;
        var startY = Layout.Pokedex.LIST_START_Y;

        for (var i = 0; i < Layout.Pokedex.VISIBLE_ROWS; i++) {
            var idx = _scroll + i;
            if (idx >= PokemonData.TOTAL_POKEMON) { break; }

            var id      = idx + 1;
            var caught  = GameState.getCaughtCount(id) > 0;
            var isShiny = GameState.shinyList.indexOf(id) != -1;
            var isBuddy = (id == GameState.buddyId);
            var isTeam  = GameState.isInTeam(id);
            var data    = PokemonData.get(id);
            var tier    = data[:tier];
            var y       = startY + (i * lineH);
            var textY   = y + 10;

            // Fondo alternado para legibilidad
            if (i % 2 == 0) {
                dc.setColor(0x0A0A12, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(20, y, w - 40, lineH);
            }

            // Highlight del buddy actual con borde verde
            if (isBuddy) {
                dc.setColor(0x0A1A0A, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(20, y, w - 40, lineH);
                dc.setColor(0x44CC44, Graphics.COLOR_TRANSPARENT);
                dc.drawRectangle(20, y, w - 40, lineH);
            } else if (isTeam) {
                dc.setColor(0x0A0A1A, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(20, y, w - 40, lineH);
                dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
                dc.drawRectangle(20, y, w - 40, lineH);
            }

            // Team/Buddy icon on the right edge
            if (caught) {
                if (isBuddy) {
                    dc.setColor(0x44CC44, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(w - Layout.Pokedex.BUDDY_ICON_X, textY, Graphics.FONT_XTINY,
                        "B", Graphics.TEXT_JUSTIFY_CENTER);
                } else if (isTeam) {
                    dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(w - Layout.Pokedex.BUDDY_ICON_X, textY, Graphics.FONT_XTINY,
                        "T", Graphics.TEXT_JUSTIFY_CENTER);
                }
            }

            // Número del Pokémon
            var numColor = caught ? tierColors[tier] : 0x1A1A1A;
            dc.setColor(numColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.Pokedex.NUM_X, textY, Graphics.FONT_XTINY,
                "#" + id.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);

            // Nombre
            var nameX = Layout.Pokedex.NAME_X;
            var nameColor = caught ? 0xDDDDDD : 0x282828;
            if (isShiny) { nameColor = 0xFFD700; }
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            var displayName = PokemonData.getName(id);
            if (!caught) { displayName = "???"; }
            if (isShiny) { displayName = "★ " + displayName; }
            dc.drawText(nameX, textY, Graphics.FONT_XTINY,
                displayName, Graphics.TEXT_JUSTIFY_LEFT);

            // Cantidad capturada / costo evolución
            if (caught) {
                var count = GameState.getCaughtCount(id);
                var cost = EvolutionManager.getRequiredCount(id);
                var countStr = "x" + count.toString();
                if (cost > 0) {
                    countStr = count.toString() + "/" + cost.toString();
                }
                dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
                dc.drawText(w - Layout.Pokedex.COUNT_X_PAD, textY, Graphics.FONT_XTINY,
                    countStr, Graphics.TEXT_JUSTIFY_RIGHT);
            }

            // Separador sutil
            dc.setColor(0x111118, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(30, y + lineH - 1, w - 30, y + lineH - 1);
        }

        // Team counter in sub-header
        var teamCount = GameState.team.size();
        var buddyAddsOne = (GameState.buddyId > 0 && !GameState.isInTeam(GameState.buddyId)) ? 1 : 0;
        var effectiveCount = teamCount + buddyAddsOne;
        if (GameState.buddyId > 0 && GameState.isInTeam(GameState.buddyId)) {
            effectiveCount = teamCount;
        }
        if (effectiveCount > 6) { effectiveCount = 6; }

        // Flash message or footer
        if (_flashFrames > 0) {
            dc.setColor(0x1A1A2A, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(80, Layout.Pokedex.FOOTER_Y, w - 160, Layout.Pokedex.FOOTER_H, 6);
            dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, Layout.Pokedex.FOOTER_Y, Graphics.FONT_XTINY,
                _flashMsg, Graphics.TEXT_JUSTIFY_CENTER);
            _flashFrames -= 1;
        } else {
            // Footer: paginación + team count
            dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(80, Layout.Pokedex.FOOTER_Y, w - 160, Layout.Pokedex.FOOTER_H, 6);
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            var page = (_scroll / Layout.Pokedex.VISIBLE_ROWS) + 1;
            var totalPages = ((PokemonData.TOTAL_POKEMON + Layout.Pokedex.VISIBLE_ROWS - 1) / Layout.Pokedex.VISIBLE_ROWS);
            dc.drawText(cx, Layout.Pokedex.FOOTER_Y, Graphics.FONT_XTINY,
                page.toString() + "/" + totalPages.toString() + " [Team:" + effectiveCount.toString() + "/6]",
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

class PokedexDelegate extends WatchUi.BehaviorDelegate {
    var _view as PokedexView;

    function initialize(view as PokedexView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Lang.Boolean {
        if (_view._scroll + Layout.Pokedex.VISIBLE_ROWS < PokemonData.TOTAL_POKEMON) {
            _view._scroll += Layout.Pokedex.VISIBLE_ROWS;
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        if (_view._scroll > 0) {
            _view._scroll -= Layout.Pokedex.VISIBLE_ROWS;
            if (_view._scroll < 0) { _view._scroll = 0; }
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Tap directo en una fila: tap izquierdo = buddy, tap derecho = team
    // Tap en footer (Team: X/6) = abrir TeamView
    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        var coords = evt.getCoordinates();
        var tapY = coords[1] as Lang.Number;
        var tapX = coords[0] as Lang.Number;

        // Tap on footer area → open TeamView
        if (tapY >= 336) {
            var v = new TeamView();
            WatchUi.pushView(v, new TeamDelegate(v), WatchUi.SLIDE_UP);
            return true;
        }

        var pickId = _view.getIdAtTapY(tapY);
        if (pickId > 0) {
            if (tapX > 180) {
                // Right side: add/remove from team
                if (GameState.isInTeam(pickId)) {
                    GameState.removeFromTeam(pickId);
                    _view.showFlash("Removed from team");
                } else {
                    var added = GameState.addToTeam(pickId);
                    if (added) {
                        _view.showFlash("Added to team!");
                    } else {
                        _view.showFlash("Team full (6/6)");
                    }
                }
            } else {
                GameState.setBuddy(pickId);
                _view.showFlash("New buddy!");
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


// ============================================================
//  PROFILE VIEW — Diseño mejorado con buddy info
// ============================================================
class ProfileView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w  = dc.getWidth();
        var cx = w / 2;

        dc.setColor(0x050508, 0x050508);
        dc.clear();

        // Header (ajustado para pantalla redonda)
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(90, Layout.Profile.HEADER_Y, w - 180, Layout.Profile.HEADER_H, 8);
        dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, Layout.Profile.TITLE_Y, Graphics.FONT_XTINY,
            tr(Rez.Strings.ProfileTitle), Graphics.TEXT_JUSTIFY_CENTER);

        var steps  = GameState.getStepsToday();
        var unique = GameState.uniqueCaught();
        var shiny  = GameState.shinyList.size();
        var streak = GameState.dailyStreak;
        var medal  = GameState.getMedal();
        var seen   = GameState.pokedexSeen.size();
        var blocks = GameState.getActivityBlocksToday();

        // Stats rows (Perfil: eliminada la sección de información de un Pokémon)
        var rows = [
            [tr(Rez.Strings.LabelStepsToday),   steps.toString(),     0xBBBBBB],
            [tr(Rez.Strings.LabelTotalSteps),   GameState.totalStepsAllTime.toString(), 0xBBBBBB],
            [tr(Rez.Strings.LabelSeen),         seen.toString() + "/" + PokemonData.TOTAL_POKEMON.toString(), 0x44CCFF],
            [tr(Rez.Strings.LabelCaught),       unique.toString() + "/" + PokemonData.TOTAL_POKEMON.toString(), 0x44FF44],
            [tr(Rez.Strings.LabelShinies),      shiny.toString(),     0xFFD700],
            [tr(Rez.Strings.LabelBlocksToday),  blocks.toString(),    0x44CCFF],
            [tr(Rez.Strings.LabelStreak),       streak.toString() + " " + tr(Rez.Strings.LabelDays), 0xFF8800],
        ];

        var y = Layout.Profile.ROWS_START_Y;
        var rowH = Layout.Profile.ROW_H;
        for (var i = 0; i < rows.size(); i++) {
            // Alternating row backgrounds
            if (i % 2 == 0) {
                dc.setColor(0x0A0A12, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(30, y - 2, w - 60, rowH);
            }

            dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
            dc.drawText(Layout.Profile.LABEL_X, y + 4, Graphics.FONT_XTINY,
                rows[i][0], Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(rows[i][2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - Layout.Profile.VALUE_X_PAD, y + 4, Graphics.FONT_XTINY,
                rows[i][1], Graphics.TEXT_JUSTIFY_RIGHT);
            y += rowH;
        }

        // Medal display
        if (!medal.equals("")) {
            var medalColor = 0xCD7F32;
            if (medal.equals("PLATA")) { medalColor = 0xC0C0C0; }
            if (medal.equals("ORO"))   { medalColor = 0xFFD700; }
            if (medal.equals("DIAMANTE")) { medalColor = 0x44CCFF; }
            dc.setColor(0x111118, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(cx - 60, y + 4, 120, 26, 8);
            dc.setColor(medalColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, y + 8, Graphics.FONT_XTINY,
                "< " + medal + " >", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}

class ProfileDelegate extends WatchUi.BehaviorDelegate {
    function initialize() { BehaviorDelegate.initialize(); }
    function onBack() as Lang.Boolean {
        WatchUi.popView(WatchUi.SLIDE_UP);
        return true;
    }
}
