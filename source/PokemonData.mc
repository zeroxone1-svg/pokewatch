// ============================================================
//  PokemonData.mc — Los 251 Pokémon (Gen 1 Kanto + Gen 2 Johto)
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
//    Legendario: 5000–12000
//
//  EVO_COST: capturas del mismo Pokémon para evolucionar.
//    0 = no evoluciona (forma final o legendario)
//
//  EVO_TO: id al que evoluciona (0 = ninguno)
//    -1 = múltiples evoluciones (ver EvolutionManager)
// ============================================================
import Toybox.Lang;

class PokemonData {

    static const TOTAL_POKEMON = 251;

    // Devuelve un diccionario con la data del Pokémon por id
    static function get(id as Lang.Number) as Lang.Dictionary {
        return DATA[id - 1];
    }

    // Nombres separados para ahorrar memoria en la tabla principal
    static function getName(id as Lang.Number) as Lang.String {
        return NAMES[id - 1];
    }

    static var NAMES as Lang.Array = [
        // ── Gen 1: Kanto (1-151) ──────────────────────────
        "Bulbasaur","Ivysaur","Venusaur","Charmander","Charmeleon",       // 1-5
        "Charizard","Squirtle","Wartortle","Blastoise","Caterpie",         // 6-10
        "Metapod","Butterfree","Weedle","Kakuna","Beedrill",              // 11-15
        "Pidgey","Pidgeotto","Pidgeot","Rattata","Raticate",              // 16-20
        "Spearow","Fearow","Ekans","Arbok","Pikachu",                    // 21-25
        "Raichu","Sandshrew","Sandslash","Nidoran-F","Nidorina",         // 26-30
        "Nidoqueen","Nidoran-M","Nidorino","Nidoking","Clefairy",        // 31-35
        "Clefable","Vulpix","Ninetales","Jigglypuff","Wigglytuff",       // 36-40
        "Zubat","Golbat","Oddish","Gloom","Vileplume",                   // 41-45
        "Paras","Parasect","Venonat","Venomoth","Diglett",               // 46-50
        "Dugtrio","Meowth","Persian","Psyduck","Golduck",                // 51-55
        "Mankey","Primeape","Growlithe","Arcanine","Poliwag",            // 56-60
        "Poliwhirl","Poliwrath","Abra","Kadabra","Alakazam",             // 61-65
        "Machop","Machoke","Machamp","Bellsprout","Weepinbell",          // 66-70
        "Victreebel","Tentacool","Tentacruel","Geodude","Graveler",      // 71-75
        "Golem","Ponyta","Rapidash","Slowpoke","Slowbro",                // 76-80
        "Magnemite","Magneton","Farfetchd","Doduo","Dodrio",             // 81-85
        "Seel","Dewgong","Grimer","Muk","Shellder",                      // 86-90
        "Cloyster","Gastly","Haunter","Gengar","Onix",                   // 91-95
        "Drowzee","Hypno","Krabby","Kingler","Voltorb",                  // 96-100
        "Electrode","Exeggcute","Exeggutor","Cubone","Marowak",          // 101-105
        "Hitmonlee","Hitmonchan","Lickitung","Koffing","Weezing",        // 106-110
        "Rhyhorn","Rhydon","Chansey","Tangela","Kangaskhan",             // 111-115
        "Horsea","Seadra","Goldeen","Seaking","Staryu",                  // 116-120
        "Starmie","Mr. Mime","Scyther","Jynx","Electabuzz",              // 121-125
        "Magmar","Pinsir","Tauros","Magikarp","Gyarados",                // 126-130
        "Lapras","Ditto","Eevee","Vaporeon","Jolteon",                   // 131-135
        "Flareon","Porygon","Omanyte","Omastar","Kabuto",                // 136-140
        "Kabutops","Aerodactyl","Snorlax","Articuno","Zapdos",           // 141-145
        "Moltres","Dratini","Dragonair","Dragonite","Mewtwo",            // 146-150
        "Mew",                                                            // 151
        // ── Gen 2: Johto (152-251) ────────────────────────
        "Chikorita","Bayleef","Meganium",                                 // 152-154
        "Cyndaquil","Quilava","Typhlosion",                               // 155-157
        "Totodile","Croconaw","Feraligatr",                               // 158-160
        "Sentret","Furret",                                               // 161-162
        "Hoothoot","Noctowl",                                             // 163-164
        "Ledyba","Ledian",                                                // 165-166
        "Spinarak","Ariados",                                             // 167-168
        "Crobat",                                                         // 169
        "Chinchou","Lanturn",                                             // 170-171
        "Pichu","Cleffa","Igglybuff",                                    // 172-174
        "Togepi","Togetic",                                               // 175-176
        "Natu","Xatu",                                                    // 177-178
        "Mareep","Flaaffy","Ampharos",                                   // 179-181
        "Bellossom",                                                      // 182
        "Marill","Azumarill",                                             // 183-184
        "Sudowoodo",                                                      // 185
        "Politoed",                                                       // 186
        "Hoppip","Skiploom","Jumpluff",                                  // 187-189
        "Aipom",                                                          // 190
        "Sunkern","Sunflora",                                             // 191-192
        "Yanma",                                                          // 193
        "Wooper","Quagsire",                                              // 194-195
        "Espeon","Umbreon",                                               // 196-197
        "Murkrow",                                                        // 198
        "Slowking",                                                       // 199
        "Misdreavus",                                                     // 200
        "Unown",                                                          // 201
        "Wobbuffet",                                                      // 202
        "Girafarig",                                                      // 203
        "Pineco","Forretress",                                            // 204-205
        "Dunsparce",                                                      // 206
        "Gligar",                                                         // 207
        "Steelix",                                                        // 208
        "Snubbull","Granbull",                                            // 209-210
        "Qwilfish",                                                       // 211
        "Scizor",                                                         // 212
        "Shuckle",                                                        // 213
        "Heracross",                                                      // 214
        "Sneasel",                                                        // 215
        "Teddiursa","Ursaring",                                           // 216-217
        "Slugma","Magcargo",                                              // 218-219
        "Swinub","Piloswine",                                             // 220-221
        "Corsola",                                                        // 222
        "Remoraid","Octillery",                                           // 223-224
        "Delibird",                                                       // 225
        "Mantine",                                                        // 226
        "Skarmory",                                                       // 227
        "Houndour","Houndoom",                                            // 228-229
        "Kingdra",                                                        // 230
        "Phanpy","Donphan",                                               // 231-232
        "Porygon2",                                                       // 233
        "Stantler",                                                       // 234
        "Smeargle",                                                       // 235
        "Tyrogue","Hitmontop",                                            // 236-237
        "Smoochum",                                                       // 238
        "Elekid",                                                         // 239
        "Magby",                                                          // 240
        "Miltank",                                                        // 241
        "Blissey",                                                        // 242
        "Raikou","Entei","Suicune",                                      // 243-245
        "Larvitar","Pupitar","Tyranitar",                                 // 246-248
        "Lugia","Ho-Oh","Celebi"                                         // 249-251
    ];

    // DATA[i] = {tier, hp, evoCost, evoTo}
    // evoTo: 0 = no evoluciona | -1 = múltiples evoluciones
    static var DATA as Lang.Array = [
        // ══════════════ Gen 1: Kanto (1-151) ══════════════
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>2   }, // 1   Bulbasaur
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>3   }, // 2   Ivysaur
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 3   Venusaur
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>5   }, // 4   Charmander
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>6   }, // 5   Charmeleon
        {  :tier=>3, :hp=>3200, :evoCost=>0,  :evoTo=>0   }, // 6   Charizard
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>8   }, // 7   Squirtle
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>9   }, // 8   Wartortle
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 9   Blastoise
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>11  }, // 10  Caterpie
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>12  }, // 11  Metapod
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 12  Butterfree
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>14  }, // 13  Weedle
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>15  }, // 14  Kakuna
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 15  Beedrill
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>17  }, // 16  Pidgey
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>18  }, // 17  Pidgeotto
        {  :tier=>2, :hp=>1300, :evoCost=>0,  :evoTo=>0   }, // 18  Pidgeot
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>20  }, // 19  Rattata
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 20  Raticate
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>22  }, // 21  Spearow
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 22  Fearow
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>24  }, // 23  Ekans
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 24  Arbok
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>26  }, // 25  Pikachu
        {  :tier=>2, :hp=>1700, :evoCost=>0,  :evoTo=>0   }, // 26  Raichu
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>28  }, // 27  Sandshrew
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 28  Sandslash
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>30  }, // 29  Nidoran-F
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>31  }, // 30  Nidorina
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 31  Nidoqueen
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>33  }, // 32  Nidoran-M
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>34  }, // 33  Nidorino
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 34  Nidoking
        {  :tier=>2, :hp=>1400, :evoCost=>100,:evoTo=>36  }, // 35  Clefairy
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 36  Clefable
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>38  }, // 37  Vulpix
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 38  Ninetales
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>40  }, // 39  Jigglypuff
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 40  Wigglytuff
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>42  }, // 41  Zubat
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>169 }, // 42  Golbat → Crobat
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>44  }, // 43  Oddish
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>-1  }, // 44  Gloom → Vileplume(45) o Bellossom(182)
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 45  Vileplume
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>47  }, // 46  Paras
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 47  Parasect
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>49  }, // 48  Venonat
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 49  Venomoth
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>51  }, // 50  Diglett
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 51  Dugtrio
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>53  }, // 52  Meowth
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 53  Persian
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>55  }, // 54  Psyduck
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 55  Golduck
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>57  }, // 56  Mankey
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 57  Primeape
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>59  }, // 58  Growlithe
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 59  Arcanine
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>61  }, // 60  Poliwag
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>-1  }, // 61  Poliwhirl → Poliwrath(62) o Politoed(186)
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 62  Poliwrath
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>64  }, // 63  Abra
        {  :tier=>2, :hp=>1400, :evoCost=>100,:evoTo=>65  }, // 64  Kadabra
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 65  Alakazam
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>67  }, // 66  Machop
        {  :tier=>2, :hp=>1500, :evoCost=>100,:evoTo=>68  }, // 67  Machoke
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 68  Machamp
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>70  }, // 69  Bellsprout
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>71  }, // 70  Weepinbell
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 71  Victreebel
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>73  }, // 72  Tentacool
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 73  Tentacruel
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>75  }, // 74  Geodude
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>76  }, // 75  Graveler
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 76  Golem
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>78  }, // 77  Ponyta
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 78  Rapidash
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>-1  }, // 79  Slowpoke → Slowbro(80) o Slowking(199)
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 80  Slowbro
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>82  }, // 81  Magnemite
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 82  Magneton
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 83  Farfetchd
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>85  }, // 84  Doduo
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 85  Dodrio
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>87  }, // 86  Seel
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 87  Dewgong
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>89  }, // 88  Grimer
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 89  Muk
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>91  }, // 90  Shellder
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 91  Cloyster
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>93  }, // 92  Gastly
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>94  }, // 93  Haunter
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 94  Gengar
        {  :tier=>1, :hp=>800,  :evoCost=>100,:evoTo=>208 }, // 95  Onix → Steelix
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>97  }, // 96  Drowzee
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 97  Hypno
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>99  }, // 98  Krabby
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 99  Kingler
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
        {  :tier=>3, :hp=>3500, :evoCost=>150,:evoTo=>242 }, // 113 Chansey → Blissey
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 114 Tangela
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 115 Kangaskhan
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>117 }, // 116 Horsea
        {  :tier=>2, :hp=>1400, :evoCost=>100,:evoTo=>230 }, // 117 Seadra → Kingdra
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>119 }, // 118 Goldeen
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 119 Seaking
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>121 }, // 120 Staryu
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 121 Starmie
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 122 Mr. Mime
        {  :tier=>3, :hp=>3000, :evoCost=>100,:evoTo=>212 }, // 123 Scyther → Scizor
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 124 Jynx
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 125 Electabuzz
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 126 Magmar
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 127 Pinsir
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 128 Tauros
        {  :tier=>0, :hp=>400,  :evoCost=>400,:evoTo=>130 }, // 129 Magikarp
        {  :tier=>3, :hp=>4000, :evoCost=>0,  :evoTo=>0   }, // 130 Gyarados
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 131 Lapras
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 132 Ditto
        {  :tier=>2, :hp=>1600, :evoCost=>100,:evoTo=>-1  }, // 133 Eevee → 5 eeveelutions
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 134 Vaporeon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 135 Jolteon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 136 Flareon
        {  :tier=>3, :hp=>2800, :evoCost=>100,:evoTo=>233 }, // 137 Porygon → Porygon2
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

        // ══════════════ Gen 2: Johto (152-251) ══════════════
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>153 }, // 152 Chikorita
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>154 }, // 153 Bayleef
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 154 Meganium
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>156 }, // 155 Cyndaquil
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>157 }, // 156 Quilava
        {  :tier=>3, :hp=>3200, :evoCost=>0,  :evoTo=>0   }, // 157 Typhlosion
        {  :tier=>2, :hp=>1400, :evoCost=>25, :evoTo=>159 }, // 158 Totodile
        {  :tier=>2, :hp=>1600, :evoCost=>50, :evoTo=>160 }, // 159 Croconaw
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 160 Feraligatr
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>162 }, // 161 Sentret
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 162 Furret
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>164 }, // 163 Hoothoot
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 164 Noctowl
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>166 }, // 165 Ledyba
        {  :tier=>1, :hp=>700,  :evoCost=>0,  :evoTo=>0   }, // 166 Ledian
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>168 }, // 167 Spinarak
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 168 Ariados
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 169 Crobat
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>171 }, // 170 Chinchou
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 171 Lanturn
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>25  }, // 172 Pichu → Pikachu
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>35  }, // 173 Cleffa → Clefairy
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>39  }, // 174 Igglybuff → Jigglypuff
        {  :tier=>2, :hp=>1300, :evoCost=>50, :evoTo=>176 }, // 175 Togepi
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 176 Togetic
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>178 }, // 177 Natu
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 178 Xatu
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>180 }, // 179 Mareep
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>181 }, // 180 Flaaffy
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 181 Ampharos
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 182 Bellossom
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>184 }, // 183 Marill
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 184 Azumarill
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 185 Sudowoodo
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 186 Politoed
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>188 }, // 187 Hoppip
        {  :tier=>1, :hp=>700,  :evoCost=>50, :evoTo=>189 }, // 188 Skiploom
        {  :tier=>2, :hp=>1300, :evoCost=>0,  :evoTo=>0   }, // 189 Jumpluff
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 190 Aipom
        {  :tier=>0, :hp=>400,  :evoCost=>25, :evoTo=>192 }, // 191 Sunkern
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 192 Sunflora
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 193 Yanma
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>195 }, // 194 Wooper
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 195 Quagsire
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 196 Espeon
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 197 Umbreon
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 198 Murkrow
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 199 Slowking
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 200 Misdreavus
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 201 Unown
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 202 Wobbuffet
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 203 Girafarig
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>205 }, // 204 Pineco
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 205 Forretress
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 206 Dunsparce
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 207 Gligar
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 208 Steelix
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>210 }, // 209 Snubbull
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 210 Granbull
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 211 Qwilfish
        {  :tier=>3, :hp=>3200, :evoCost=>0,  :evoTo=>0   }, // 212 Scizor
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 213 Shuckle
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 214 Heracross
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 215 Sneasel
        {  :tier=>1, :hp=>800,  :evoCost=>50, :evoTo=>217 }, // 216 Teddiursa
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 217 Ursaring
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>219 }, // 218 Slugma
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 219 Magcargo
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>221 }, // 220 Swinub
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 221 Piloswine
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 222 Corsola
        {  :tier=>0, :hp=>420,  :evoCost=>25, :evoTo=>224 }, // 223 Remoraid
        {  :tier=>1, :hp=>750,  :evoCost=>0,  :evoTo=>0   }, // 224 Octillery
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 225 Delibird
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 226 Mantine
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 227 Skarmory
        {  :tier=>1, :hp=>750,  :evoCost=>50, :evoTo=>229 }, // 228 Houndour
        {  :tier=>2, :hp=>1600, :evoCost=>0,  :evoTo=>0   }, // 229 Houndoom
        {  :tier=>3, :hp=>3000, :evoCost=>0,  :evoTo=>0   }, // 230 Kingdra
        {  :tier=>0, :hp=>450,  :evoCost=>25, :evoTo=>232 }, // 231 Phanpy
        {  :tier=>1, :hp=>800,  :evoCost=>0,  :evoTo=>0   }, // 232 Donphan
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 233 Porygon2
        {  :tier=>2, :hp=>1500, :evoCost=>0,  :evoTo=>0   }, // 234 Stantler
        {  :tier=>2, :hp=>1400, :evoCost=>0,  :evoTo=>0   }, // 235 Smeargle
        {  :tier=>2, :hp=>1400, :evoCost=>50, :evoTo=>-1  }, // 236 Tyrogue → Hit-trio
        {  :tier=>3, :hp=>2800, :evoCost=>0,  :evoTo=>0   }, // 237 Hitmontop
        {  :tier=>1, :hp=>700,  :evoCost=>25, :evoTo=>124 }, // 238 Smoochum → Jynx
        {  :tier=>1, :hp=>700,  :evoCost=>25, :evoTo=>125 }, // 239 Elekid → Electabuzz
        {  :tier=>1, :hp=>700,  :evoCost=>25, :evoTo=>126 }, // 240 Magby → Magmar
        {  :tier=>3, :hp=>3500, :evoCost=>0,  :evoTo=>0   }, // 241 Miltank
        {  :tier=>3, :hp=>4000, :evoCost=>0,  :evoTo=>0   }, // 242 Blissey
        {  :tier=>4, :hp=>5500, :evoCost=>0,  :evoTo=>0   }, // 243 Raikou   (quest)
        {  :tier=>4, :hp=>5500, :evoCost=>0,  :evoTo=>0   }, // 244 Entei    (quest)
        {  :tier=>4, :hp=>5500, :evoCost=>0,  :evoTo=>0   }, // 245 Suicune  (quest)
        {  :tier=>2, :hp=>1600, :evoCost=>100,:evoTo=>247 }, // 246 Larvitar
        {  :tier=>3, :hp=>3000, :evoCost=>150,:evoTo=>248 }, // 247 Pupitar
        {  :tier=>4, :hp=>9000, :evoCost=>0,  :evoTo=>0   }, // 248 Tyranitar
        {  :tier=>4, :hp=>7000, :evoCost=>0,  :evoTo=>0   }, // 249 Lugia    (quest)
        {  :tier=>4, :hp=>7000, :evoCost=>0,  :evoTo=>0   }, // 250 Ho-Oh    (quest)
        {  :tier=>4, :hp=>5000, :evoCost=>0,  :evoTo=>0   }, // 251 Celebi   (quest)
    ];
}
