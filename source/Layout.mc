// ============================================================
//  Layout.mc — Posiciones centralizadas de TODAS las vistas
//
//  CÓMO USAR: Cambia cualquier número aquí y recompila.
//  Pantalla vivoactive6: 390x390 (redonda).
//  Y=0 es arriba, Y=390 es abajo. X=195 es el centro.
//
//  Cada sección tiene el nombre de la vista y comentarios
//  describiendo qué hace cada constante.
// ============================================================
import Toybox.Lang;

module Layout {

    // ════════════════════════════════════════════════════
    //  MAIN VIEW — Pantalla principal (buddy, hora, spawn)
    // ════════════════════════════════════════════════════
    module Main {
        const CLOCK_Y       = 5;     // hora grande arriba
        const STEPS_Y       = 50;    // "1234 pasos"
        const BOX_SIZE      = 96;    // cuadro del sprite (96x96)
        const BOX_Y         = 80;    // borde superior del cuadro
        const NAME_Y        = 182;   // nombre del pokémon (debajo del box)
        const BUDDY_BAR_Y   = 222;   // barra de nivel del buddy
        const BUDDY_BAR_W   = 100;   // ancho barra nivel buddy
        const BUDDY_BAR_H   = 5;     // alto barra nivel buddy
        const BUDDY_TXT_Y   = 237;   // "Lvl up: 500 p."
        const INFO_Y        = 265;   // zona de info/encounter/battle alert
        const INFO_W        = 170;   // ancho del recuadro de info
        const INFO_H        = 40;    // alto del recuadro de info
        const DOTS_Y        = 296;   // primera fila de medal dots (Kanto)
        const DOTS_SPACING  = 12;    // espaciado entre dots
        const DOTS_RADIUS   = 3;     // radio del dot
        const FOOT_Y        = 320;   // pie: dex, batería, racha
    }

    // ════════════════════════════════════════════════════
    //  ENCOUNTER VIEW — Encuentro con Pokémon salvaje
    // ════════════════════════════════════════════════════
    module Encounter {
        // Header (nombre + tier)
        const HEADER_Y      = 8;     // fondo del header
        const HEADER_H      = 54;    // alto del header
        const HEADER_RADIUS = 8;
        const NAME_Y        = 12;    // nombre del pokémon
        const TIER_Y        = 38;    // tier + #número

        // Sprite
        const SPRITE_Y      = 70;    // borde superior cuadro sprite
        const SPRITE_SIZE   = 100;   // tamaño del sprite
        const BOX_PAD       = 6;     // padding extra del borde (112x112)
        const BOX_RADIUS    = 10;

        // HP Bar
        const HP_BAR_W      = 140;   // ancho barra HP
        const HP_BAR_H      = 10;    // alto barra HP
        const HP_BAR_RADIUS = 4;

        // Botón huir
        const FLEE_BTN_W    = 140;   // ancho botón huir
        const FLEE_BTN_H    = 30;    // alto botón huir
        const FLEE_BTN_PAD  = 78;    // distancia desde abajo: h - este valor

        // Captura (pantalla resultado)
        const CAPTURE_SPRITE_Y = 30; // sprite en resultado captura
        const CAPTURE_RADIUS   = 100;// radio del círculo de fondo

        // Reloj
        const CLOCK_Y       = 338;
    }

    // ════════════════════════════════════════════════════
    //  BATTLE VIEW — Batalla contra gym/trainer
    // ════════════════════════════════════════════════════
    module Battle {
        // Header
        const TRAINER_NAME_Y  = 16;    // nombre del líder/trainer

        // Sprite rival
        const SPRITE_Y        = 38;    // borde superior del cuadro
        const SPRITE_SIZE     = 0;    // ancho y alto del cuadro
        const SPRITE_RADIUS   = 8;     // bordes redondeados

        // Info rival
        const RIVAL_NAME_Y    = 140;   // "ONIX Lv.14"

        // HP Bar rival (verde, baja con pasos)
        const RIVAL_BAR_Y     = 170;
        const BAR_WIDTH       = 170;   // ancho de AMBAS barras
        const BAR_HEIGHT      = 5;     // alto de AMBAS barras
        const BAR_RADIUS      = 2;     // bordes redondeados

        // Entre barras: buddy label, tiempo, pasos (centrados)
        const TEAM_LABEL_Y    = 225;   // "SANDSLASH Lv.14" (nombre buddy + nivel equipo)
        const TIME_TEXT_Y     = 202;   // "44:58 restante"
        const STEPS_TEXT_Y    = 170;   // "0/2000 pasos"

        // HP Bar equipo (azul, baja con tiempo)
        const TEAM_BAR_Y      = 260;

        // Buddy
        const BUDDY_Y         = 240;   // sprite del buddy
        const BUDDY_OFFSET_X  = 120;    // centrado: cx - este valor

        // Reloj
        const CLOCK_Y         = 340;

        // Resultado (Victoria/Derrota)
        const RESULT_RADIUS   = 100;   // radio círculo de fondo
    }

    // ════════════════════════════════════════════════════
    //  POKEDEX VIEW — Lista de Pokémon
    // ════════════════════════════════════════════════════
    module Pokedex {
        const HEADER_Y      = 4;     // fondo header
        const HEADER_H      = 24;
        const TITLE_Y       = 6;     // "POKÉDEX"
        const STATS_Y       = 26;    // "45v | 30c | 2sh"
        const LIST_START_Y  = 56;    // primera fila de la lista
        const LINE_H        = 40;    // alto de cada fila
        const VISIBLE_ROWS  = 7;     // filas visibles
        const NUM_X         = 45;    // posición X del #número
        const NAME_X        = 75;    // posición X del nombre
        const COUNT_X_PAD   = 28;    // w - este valor para el conteo
        const BUDDY_ICON_X  = 16;    // w - este valor para B/T icon
        const FOOTER_Y      = 340;   // pie con paginación
        const FOOTER_H      = 18;
    }

    // ════════════════════════════════════════════════════
    //  TEAM VIEW — Equipo de 6 Pokémon
    // ════════════════════════════════════════════════════
    module Team {
        const HEADER_Y      = 4;     // fondo header
        const HEADER_H      = 24;
        const TITLE_Y       = 6;     // "TEAM"
        const STATS_Y       = 28;    // "3/6 Avg Lv.14"
        const LIST_START_Y  = 62;    // primera fila
        const SLOT_H        = 42;    // alto de cada slot
        const SLOT_NUM_X    = 44;    // posición X del número de slot
        const NAME_X        = 60;    // posición X del nombre
        const LEVEL_X_PAD   = 40;    // w - este valor para "Lv.XX"
        const FOOTER_Y      = 320;   // pie
        const FOOTER_H      = 22;
    }

    // ════════════════════════════════════════════════════
    //  GYM LIST VIEW — Lista de gimnasios
    // ════════════════════════════════════════════════════
    module Gym {
        const HEADER_BG_Y   = 30;    // fondo header
        const HEADER_BG_H   = 24;
        const TITLE_Y       = 32;    // "GYMS & ELITE FOUR"
        const STATS_Y       = 65;    // "8/20 medals  5 wins"
        const LIST_START_Y  = 120;    // primera fila
        const LINE_H        = 50;    // alto de cada fila
        const VISIBLE_ROWS  = 4;     // filas visibles
        const ROW_PAD       = 24;    // padding horizontal (24 a cada lado)
        const ARROW_X       = 30;    // ">" de selección
        const NUM_X         = 50;    // número del gym (01-20)
        const NAME_X        = 68;    // nombre del líder
        const STATUS_X_PAD  = 38;    // w - este valor para LOCKED/GO!/WON
        const FOOTER_PAD    = 68;    // h - este valor para el footer
    }

    // ════════════════════════════════════════════════════
    //  PROFILE VIEW — Estadísticas del jugador
    // ════════════════════════════════════════════════════
    module Profile {
        const HEADER_Y      = 22;    // fondo header
        const HEADER_H      = 26;
        const TITLE_Y       = 24;    // "PERFIL TRAINER"
        const ROWS_START_Y  = 70;    // primera fila de stats
        const ROW_H         = 34;    // alto de cada fila
        const LABEL_X       = 36;    // X del label (izquierda)
        const VALUE_X_PAD   = 36;    // w - este valor para el valor (derecha)
    }
}
