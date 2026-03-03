// ============================================================
//  PokedexView.mc — Lista de los 151 Pokémon con estado.
//  ProfileView.mc — Estadísticas del jugador.
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

// ============================================================
//  POKÉDEX VIEW
// ============================================================
class PokedexView extends WatchUi.View {

    var _scroll as Lang.Number = 0;
    static const LINES = 7;         // líneas visibles

    function initialize() {
        View.initialize();
    }

    function tr(resourceId) as Lang.String {
        return WatchUi.loadResource(resourceId) as Lang.String;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Título compacto
        dc.setColor(0xFFCC00, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 14, Graphics.FONT_XTINY,
            tr(Rez.Strings.KantoTitle), Graphics.TEXT_JUSTIFY_CENTER);

        var unique = GameState.uniqueCaught();
        var seen = GameState.pokedexSeen.size();
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 32, Graphics.FONT_XTINY,
            seen.toString() + " " + tr(Rez.Strings.SeenShort) + " | " +
            unique.toString() + " " + tr(Rez.Strings.CaughtShort) + "  |  " +
            GameState.shinyList.size().toString() + " " + tr(Rez.Strings.ShiniesShort),
            Graphics.TEXT_JUSTIFY_CENTER);

        var tierColors = [0xAAAAAA, 0x44CC44, 0x4488FF, 0xFF66FF, 0xFFAA00];
        var lineH  = 40;
        var startY = 58;

        for (var i = 0; i < LINES; i++) {
            var idx = _scroll + i;
            if (idx >= 151) { break; }

            var id      = idx + 1;
            var caught  = GameState.getCaughtCount(id) > 0;
            var isShiny = GameState.shinyList.indexOf(id) != -1;
            var data    = PokemonData.get(id);
            var tier    = data[:tier];
            var y       = startY + (i * lineH);
            var textY   = y + 10;

            // Número del Pokémon
            var numColor = caught ? tierColors[tier] : 0x222222;
            dc.setColor(numColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(45, textY, Graphics.FONT_XTINY,
                "#" + id.format("%03d"), Graphics.TEXT_JUSTIFY_CENTER);

            // Nombre
            var nameColor = caught ? Graphics.COLOR_WHITE : 0x333333;
            dc.setColor(nameColor, Graphics.COLOR_TRANSPARENT);
            var displayName = PokemonData.getName(id);
            if (!caught) { displayName = "???"; }
            if (isShiny) { displayName = "★ " + displayName; }
            dc.drawText(80, textY, Graphics.FONT_XTINY,
                displayName, Graphics.TEXT_JUSTIFY_LEFT);

            // Cantidad capturada
            if (caught) {
                var count = GameState.getCaughtCount(id);
                var cost    = EvolutionManager.getRequiredCount(id);
                var countStr = "x" + count.toString();
                if (cost > 0) {
                    countStr = count.toString() + "/" + cost.toString();
                }
                dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
                dc.drawText(w - 30, textY, Graphics.FONT_XTINY,
                    countStr, Graphics.TEXT_JUSTIFY_RIGHT);
            }

            // Separador sutil
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(30, y + lineH - 1, w - 30, y + lineH - 1);
        }

        // Indicador de scroll
        dc.setColor(0x333333, Graphics.COLOR_TRANSPARENT);
        var page = (_scroll / LINES) + 1;
        var totalPages = ((151 + LINES - 1) / LINES);
        dc.drawText(cx, 345, Graphics.FONT_XTINY,
            page.toString() + "/" + totalPages.toString(),
            Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PokedexDelegate extends WatchUi.BehaviorDelegate {
    function initialize() { BehaviorDelegate.initialize(); }

    function onNextPage() as Lang.Boolean {
        var view = WatchUi.getCurrentView()[0] as PokedexView;
        if (view._scroll + PokedexView.LINES < 151) {
            view._scroll += PokedexView.LINES;
            WatchUi.requestUpdate();
        }
        return true;
    }

    function onPreviousPage() as Lang.Boolean {
        var view = WatchUi.getCurrentView()[0] as PokedexView;
        if (view._scroll > 0) {
            view._scroll -= PokedexView.LINES;
            if (view._scroll < 0) { view._scroll = 0; }
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
//  PROFILE VIEW
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

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Título
        dc.setColor(0x4488FF, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 22, Graphics.FONT_XTINY,
            tr(Rez.Strings.ProfileTitle), Graphics.TEXT_JUSTIFY_CENTER);

        var steps  = GameState.getStepsToday();
        var unique = GameState.uniqueCaught();
        var shiny  = GameState.shinyList.size();
        var streak = GameState.dailyStreak;
        var medal  = GameState.getMedal();
        var seen   = GameState.pokedexSeen.size();

        var rows = [
            [tr(Rez.Strings.LabelStepsToday),   steps.toString()],
            [tr(Rez.Strings.LabelSeen),         seen.toString() + "/151"],
            [tr(Rez.Strings.LabelCaught),       unique.toString() + "/151"],
            [tr(Rez.Strings.LabelShinies),      shiny.toString()],
            [tr(Rez.Strings.LabelStreak),       streak.toString() + " " + tr(Rez.Strings.LabelDays)],
            [tr(Rez.Strings.LabelMedal),        medal.equals("") ? "---" : medal],
        ];

        var y = 55;
        var rowH = 38;
        for (var i = 0; i < rows.size(); i++) {
            dc.setColor(0x444444, Graphics.COLOR_TRANSPARENT);
            dc.drawText(30, y, Graphics.FONT_XTINY,
                rows[i][0], Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w - 30, y, Graphics.FONT_XTINY,
                rows[i][1], Graphics.TEXT_JUSTIFY_RIGHT);
            dc.setColor(0x111111, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(30, y + 20, w - 30, y + 20);
            y += rowH;
        }

        // Medalla visual
        if (!medal.equals("")) {
            var medalColor = 0xCD7F32;
            if (medal.equals("PLATA")) { medalColor = 0xC0C0C0; }
            if (medal.equals("ORO"))   { medalColor = 0xFFD700; }
            dc.setColor(medalColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, y + 10, Graphics.FONT_XTINY,
                "★ " + medal + " ★", Graphics.TEXT_JUSTIFY_CENTER);
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
