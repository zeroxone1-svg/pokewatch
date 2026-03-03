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

    function initialize() {
        View.initialize();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    // Dado un tap en coordenada Y, devolver el id del Pokémon en esa fila.
    // Retorna 0 si no corresponde a ninguna fila válida o no está capturado.
    function getIdAtTapY(tapY as Lang.Number) as Lang.Number {
        var startY = 56;
        var lineH  = 40;
        if (tapY < startY || tapY >= startY + 7 * lineH) {
            return 0;
        }
        var row = (tapY - startY) / lineH;
        var idx = _scroll + row;
        if (idx < 0 || idx >= 151) { return 0; }
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
        dc.fillRoundedRectangle(100, 8, w - 200, 24, 8);

        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 10, Graphics.FONT_XTINY,
            tr(Rez.Strings.KantoTitle), Graphics.TEXT_JUSTIFY_CENTER);

        // Stats: vistos / capturados / shinies
        var unique = GameState.uniqueCaught();
        var seen = GameState.pokedexSeen.size();
        dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 34, Graphics.FONT_XTINY,
            seen.toString() + "v | " +
            unique.toString() + "c | " +
            GameState.shinyList.size().toString() + "sh",
            Graphics.TEXT_JUSTIFY_CENTER);

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var lineH  = 40;
        var startY = 56;

        for (var i = 0; i < 7; i++) {
            var idx = _scroll + i;
            if (idx >= 151) { break; }

            var id      = idx + 1;
            var caught  = GameState.getCaughtCount(id) > 0;
            var isShiny = GameState.shinyList.indexOf(id) != -1;
            var isBuddy = (id == GameState.buddyId);
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
            }

            // Número del Pokémon
            var numColor = caught ? tierColors[tier] : 0x1A1A1A;
            dc.setColor(numColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(45, textY, Graphics.FONT_XTINY,
                "#" + id.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);

            // Nombre
            var nameX = 75;
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
                dc.drawText(w - 28, textY, Graphics.FONT_XTINY,
                    countStr, Graphics.TEXT_JUSTIFY_RIGHT);
            }

            // Separador sutil
            dc.setColor(0x111118, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(30, y + lineH - 1, w - 30, y + lineH - 1);
        }

        // Footer: paginación + hint buddy
        dc.setColor(0x0F0F18, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(80, 340, w - 160, 18, 6);
        dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
        var page = (_scroll / 7) + 1;
        var totalPages = ((151 + 6) / 7);
        dc.drawText(cx, 340, Graphics.FONT_XTINY,
            page.toString() + "/" + totalPages.toString() + " Tap=buddy",
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PokedexDelegate extends WatchUi.BehaviorDelegate {
    var _view as PokedexView;

    function initialize(view as PokedexView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Lang.Boolean {
        if (_view._scroll + 7 < 151) {
            _view._scroll += 7;
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        if (_view._scroll > 0) {
            _view._scroll -= 7;
            if (_view._scroll < 0) { _view._scroll = 0; }
            WatchUi.requestUpdate();
        }
        return true;
    }

    // Tap directo en una fila para elegir buddy
    function onTap(evt as WatchUi.ClickEvent) as Lang.Boolean {
        var coords = evt.getCoordinates();
        var tapY = coords[1] as Lang.Number;
        var pickId = _view.getIdAtTapY(tapY);
        if (pickId > 0) {
            GameState.setBuddy(pickId);
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
        dc.fillRoundedRectangle(90, 22, w - 180, 26, 8);
        dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 24, Graphics.FONT_XTINY,
            tr(Rez.Strings.ProfileTitle), Graphics.TEXT_JUSTIFY_CENTER);

        var steps  = GameState.getStepsToday();
        var unique = GameState.uniqueCaught();
        var shiny  = GameState.shinyList.size();
        var streak = GameState.dailyStreak;
        var medal  = GameState.getMedal();
        var seen   = GameState.pokedexSeen.size();
        var blocks = GameState.getActivityBlocksToday();

        // Buddy section (centrado para pantalla redonda)
        var buddyY = 56;
        if (GameState.buddyId > 0) {
            var buddyData = PokemonData.get(GameState.buddyId);
            var buddyTier = buddyData[:tier];
            var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];

            dc.setColor(0x1A1A00, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(55, buddyY - 4, w - 110, 26, 8);

            // Progreso buddy (basado en nivel)
            var evoLevel = GameState.getBuddyEvoLevel();
            if (evoLevel > 0) {
                var progress = GameState.getBuddyProgress();
                dc.setColor(tierColors[buddyTier], Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, buddyY, Graphics.FONT_XTINY,
                    "#" + GameState.buddyId.format("%03d") + " - " + progress.toString() + "%",
                    Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                dc.setColor(0x666666, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, buddyY, Graphics.FONT_XTINY,
                    "#" + GameState.buddyId.format("%03d") + " - " + tr(Rez.Strings.BuddyMaxForm),
                    Graphics.TEXT_JUSTIFY_CENTER);
            }
        } else {
            dc.setColor(0x111118, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(55, buddyY - 4, w - 110, 26, 8);
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, buddyY, Graphics.FONT_XTINY,
                tr(Rez.Strings.BuddyHint), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Stats rows
        var rows = [
            [tr(Rez.Strings.LabelStepsToday),   steps.toString(),     0xBBBBBB],
            [tr(Rez.Strings.LabelSeen),         seen.toString() + "/151", 0x44CCFF],
            [tr(Rez.Strings.LabelCaught),       unique.toString() + "/151", 0x44FF44],
            [tr(Rez.Strings.LabelShinies),      shiny.toString(),     0xFFD700],
            [tr(Rez.Strings.LabelBlocksToday),  blocks.toString(),    0x44CCFF],
            [tr(Rez.Strings.LabelStreak),       streak.toString() + " " + tr(Rez.Strings.LabelDays), 0xFF8800],
        ];

        var y = (GameState.buddyId > 0) ? 90 : 86;
        var rowH = 34;
        for (var i = 0; i < rows.size(); i++) {
            // Alternating row backgrounds
            if (i % 2 == 0) {
                dc.setColor(0x0A0A12, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(30, y - 2, w - 60, rowH);
            }

            dc.setColor(0x777777, Graphics.COLOR_TRANSPARENT);
            dc.drawText(36, y + 4, Graphics.FONT_XTINY,
                rows[i][0], Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(rows[i][2], Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - 36, y + 4, Graphics.FONT_XTINY,
                rows[i][1], Graphics.TEXT_JUSTIFY_RIGHT);
            y += rowH;
        }

        // Medal display
        if (!medal.equals("")) {
            var medalColor = 0xCD7F32;
            if (medal.equals("PLATA")) { medalColor = 0xC0C0C0; }
            if (medal.equals("ORO"))   { medalColor = 0xFFD700; }
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
