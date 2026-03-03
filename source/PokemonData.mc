// ============================================================
//  PokemonData.mc — Los 151 Pokémon con toda su data:
//  nombre, tier, HP base, capturas para evolucionar, evolución.
//
//  TIERS:
//    0 = Común       (55% spawn)
//    1 = Poco común  (25% spawn)
//    2 = Raro        (12% spawn)
//    3 = Muy raro    ( 6% spawn)
//    4 = Legendario  ( 2% spawn)
//
//  HP_BASE: pasos necesarios para debilitar desde HP lleno.
//    Común:      400–600
//    Poco común: 700–1000
//    Raro:       1200–1800
//    Muy raro:   2500–4000
//    Legendario: 8000–12000
//
//  EVO_COST: capturas del mismo Pokémon para evolucionar.
//    0 = no evoluciona (forma final o legendario)
//
//  EVO_TO: id al que evoluciona (0 = ninguno)
// ============================================================
import Toybox.Lang;

class PokemonData {

    // Devuelve un diccionario con la data del Pokémon por id
    static function get(id as Lang.Number) as Lang.Dictionary {
        return DATA[id - 1];
    }

    // Nombres separados para ahorrar memoria en la tabla principal
    static function getName(id as Lang.Number) as Lang.String {
        return NAMES[id - 1];
    }

    static var NAMES as Lang.Array = [
        "Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon",
        "Charizard","Squirtle","Wartortle","Blastoise","Caterpie",
        "Metapod","Butterfree","Weedle","Kakuna","Beedrill",
        "Pidgey","Pidgeotto","Pidgeot","Rattata","Raticate",
        "Spearow","Fearow","Ekans","Arbok","Pikachu",
        "Raichu","Sandshrew","Sandslash","Nidoran-F","Nidorina",
        "Nidoqueen","Nidoran-M","Nidorino","Nidoking","Clefairy",
        "Clefable","Vulpix","Ninetales","Jigglypuff","Wigglytuff",
        "Zubat","Golbat","Oddish","Gloom","Vileplume",
        "Paras","Parasect","Venonat","Venomoth","Diglett",
        "Dugtrio","Meowth","Persian","Psyduck","Golduck",
        "Mankey","Primeape","Growlithe","Arcanine","Poliwag",
        "Poliwhirl","Poliwrath","Abra","Kadabra","Alakazam",
        "Machop","Machoke","Machamp","Bellsprout","Weepinbell",
        "Victreebel","Tentacool","Tentacruel","Geodude","Graveler",
        "Golem","Ponyta","Rapidash","Slowpoke","Slowbro",
        "Magnemite","Magneton","Farfetchd","Doduo","Dodrio",
        "Seel","Dewgong","Grimer","Muk","Shellder",
        "Cloyster","Gastly","Haunter","Gengar","Onix",
        "Drowzee","Hypno","Krabby","Kingler","Voltorb",
        "Electrode","Exeggcute","Exeggutor","Cubone","Marowak",
        "Hitmonlee","Hitmonchan","Lickitung","Koffing","Weezing",
        "Rhyhorn","Rhydon","Chansey","Tangela","Kangaskhan",
        "Horsea","Seadra","Goldeen","Seaking","Staryu",
        "Starmie","Mr. Mime","Scyther","Jynx","Electabuzz",
        "Magmar","Pinsir","Tauros","Magikarp","Gyarados",
        "Lapras","Ditto","Eevee","Vaporeon","Jolteon",
        "Flareon","Porygon","Omanyte","Omastar","Kabuto",
        "Kabutops","Aerodactyl","Snorlax","Articuno","Zapdos",
        "Moltres","Dratini","Dragonair","Dragonite","Mewtwo",
        "Mew"
    ];

    // DATA[i] = {tier, hp, evoCost, evoTo}
    // evoTo: 0 = no evoluciona | -1 = múltiples evoluciones (ej. Eevee)
    static var DATA as Lang.Array = [
        // id  tier  hp    evoCost  evoTo
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>2   }, // 1  Bulbasaur
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>3   }, // 2  Ivysaur
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 3  Venusaur
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>5   }, // 4  Charmander
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>6   }, // 5  Charmeleon
        {  :tier=>3, :hp=>3200, :evoCost=>0,  :evoTo=>0   }, // 6  Charizard
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>8   }, // 7  Squirtle
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>9   }, // 8  Wartortle
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 9  Blastoise
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>11  }, // 10 Caterpie
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>12  }, // 11 Metapod
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 12 Butterfree
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>14  }, // 13 Weedle
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>15  }, // 14 Kakuna
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 15 Beedrill
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>17  }, // 16 Pidgey
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>18  }, // 17 Pidgeotto
        {  :tier=>2, :hp=>1300, :evoCost=>0,  :evoTo=>0   }, // 18 Pidgeot
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>20  }, // 19 Rattata
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 20 Raticate
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>22  }, // 21 Spearow
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 22 Fearow
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>24  }, // 23 Ekans
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 24 Arbok
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>26  }, // 25 Pikachu ⭐
        {  :tier=>2, :hp=>1700, :evoCost=>0,  :evoTo=>0   }, // 26 Raichu
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>28  }, // 27 Sandshrew
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 28 Sandslash
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>30  }, // 29 Nidoran-F
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>31  }, // 30 Nidorina
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 31 Nidoqueen
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>33  }, // 32 Nidoran-M
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>34  }, // 33 Nidorino
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 34 Nidoking
        {  :tier=>2, :hp=>1400, :evoCost=>100,:evoTo=>36  }, // 35 Clefairy
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 36 Clefable
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>38  }, // 37 Vulpix
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 38 Ninetales
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>40  }, // 39 Jigglypuff
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 40 Wigglytuff
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>42  }, // 41 Zubat
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 42 Golbat
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>44  }, // 43 Oddish
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>45  }, // 44 Gloom
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 45 Vileplume
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>47  }, // 46 Paras
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 47 Parasect
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>49  }, // 48 Venonat
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 49 Venomoth
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>51  }, // 50 Diglett
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 51 Dugtrio
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>53  }, // 52 Meowth
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 53 Persian
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>55  }, // 54 Psyduck
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 55 Golduck
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>57  }, // 56 Mankey
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 57 Primeape
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>59  }, // 58 Growlithe
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 59 Arcanine
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>61  }, // 60 Poliwag
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>62  }, // 61 Poliwhirl
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 62 Poliwrath
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>64  }, // 63 Abra
        {  :tier=>2, :hp=>1400, :evoCost=>100,:evoTo=>65  }, // 64 Kadabra
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 65 Alakazam
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>67  }, // 66 Machop
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>68  }, // 67 Machoke
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 68 Machamp
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>70  }, // 69 Bellsprout
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>71  }, // 70 Weepinbell
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 71 Victreebel
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>73  }, // 72 Tentacool
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 73 Tentacruel
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>75  }, // 74 Geodude
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>76  }, // 75 Graveler
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 76 Golem
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>78  }, // 77 Ponyta
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 78 Rapidash
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>80  }, // 79 Slowpoke
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 80 Slowbro
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>82  }, // 81 Magnemite
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 82 Magneton
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 83 Farfetchd
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>85  }, // 84 Doduo
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 85 Dodrio
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>87  }, // 86 Seel
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 87 Dewgong
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>89  }, // 88 Grimer
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 89 Muk
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>91  }, // 90 Shellder
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 91 Cloyster
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>93  }, // 92 Gastly
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>94  }, // 93 Haunter
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 94 Gengar
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 95 Onix
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>97  }, // 96 Drowzee
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 97 Hypno
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>99  }, // 98 Krabby
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 99 Kingler
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>101 }, // 100 Voltorb
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 101 Electrode
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>103 }, // 102 Exeggcute
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 103 Exeggutor
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>105 }, // 104 Cubone
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 105 Marowak
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 106 Hitmonlee
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 107 Hitmonchan
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 108 Lickitung
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>110 }, // 109 Koffing
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 110 Weezing
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>112 }, // 111 Rhyhorn
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 112 Rhydon
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 113 Chansey
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 114 Tangela
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 115 Kangaskhan
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>117 }, // 116 Horsea
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 117 Seadra
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>119 }, // 118 Goldeen
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 119 Seaking
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>121 }, // 120 Staryu
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 121 Starmie
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 122 Mr. Mime
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 123 Scyther
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 124 Jynx
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 125 Electabuzz
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 126 Magmar
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 127 Pinsir
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 128 Tauros
        {  :tier=>0, :hp=>400,  :evoCost=>400,:evoTo=>130 }, // 129 Magikarp (requiere MAS capturas!)
        {  :tier=>3, :hp=>4000, :evoCost=>0,  :evoTo=>0   }, // 130 Gyarados
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 131 Lapras
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 132 Ditto
        {  :tier=>2, :hp=>1600, :evoCost=>100,:evoTo=>-1  }, // 133 Eevee → múltiples
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 134 Vaporeon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 135 Jolteon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 136 Flareon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 137 Porygon
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>139 }, // 138 Omanyte
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 139 Omastar
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>141 }, // 140 Kabuto
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 141 Kabutops
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 142 Aerodactyl
        {  :tier=>3, :hp=>4000, :evoCost=>0,  :evoTo=>0   }, // 143 Snorlax
        {  :tier=>4, :hp=>5000, :evoCost=>0,  :evoTo=>0   }, // 144 Articuno  (quest)
        {  :tier=>4, :hp=>5000, :evoCost=>0,  :evoTo=>0   }, // 145 Zapdos    (quest)
        {  :tier=>4, :hp=>5000, :evoCost=>0,  :evoTo=>0   }, // 146 Moltres   (quest)
        {  :tier=>2, :hp=>1600, :evoCost=>100,:evoTo=>148 }, // 147 Dratini
        {  :tier=>3, :hp=>3000, :evoCost=>150,:evoTo=>149 }, // 148 Dragonair
        {  :tier=>4, :hp=>9000, :evoCost=>0,  :evoTo=>0   }, // 149 Dragonite
        {  :tier=>4, :hp=>6000, :evoCost=>0,  :evoTo=>0   }, // 150 Mewtwo    (quest)
        {  :tier=>4, :hp=>4000, :evoCost=>0,  :evoTo=>0   }, // 151 Mew       (quest)
    ];
}
