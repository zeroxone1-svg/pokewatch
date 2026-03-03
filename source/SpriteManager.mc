// ============================================================
//  SpriteManager.mc — Carga segura de sprites de Pokémon
// ============================================================
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;

class SpriteManager {

    // Obtener el sprite de un Pokémon por ID
    static function getSprite(id as Lang.Number) as Object? {
        var spriteName = "pk" + formatId(id);
        
        try {
            // Intentar cargar desde los recursos compilados
            // Los sprites se généraron en sprites.xml como pk001, pk002, etc.
            switch (id) {
                case 1: return WatchUi.loadResource(Rez.Drawables.pk001);
                case 2: return WatchUi.loadResource(Rez.Drawables.pk002);
                case 3: return WatchUi.loadResource(Rez.Drawables.pk003);
                case 4: return WatchUi.loadResource(Rez.Drawables.pk004);
                case 5: return WatchUi.loadResource(Rez.Drawables.pk005);
                case 6: return WatchUi.loadResource(Rez.Drawables.pk006);
                case 7: return WatchUi.loadResource(Rez.Drawables.pk007);
                case 8: return WatchUi.loadResource(Rez.Drawables.pk008);
                case 9: return WatchUi.loadResource(Rez.Drawables.pk009);
                case 10: return WatchUi.loadResource(Rez.Drawables.pk010);
                case 11: return WatchUi.loadResource(Rez.Drawables.pk011);
                case 12: return WatchUi.loadResource(Rez.Drawables.pk012);
                case 13: return WatchUi.loadResource(Rez.Drawables.pk013);
                case 14: return WatchUi.loadResource(Rez.Drawables.pk014);
                case 15: return WatchUi.loadResource(Rez.Drawables.pk015);
                case 16: return WatchUi.loadResource(Rez.Drawables.pk016);
                case 17: return WatchUi.loadResource(Rez.Drawables.pk017);
                case 18: return WatchUi.loadResource(Rez.Drawables.pk018);
                case 19: return WatchUi.loadResource(Rez.Drawables.pk019);
                case 20: return WatchUi.loadResource(Rez.Drawables.pk020);
                case 21: return WatchUi.loadResource(Rez.Drawables.pk021);
                case 22: return WatchUi.loadResource(Rez.Drawables.pk022);
                case 23: return WatchUi.loadResource(Rez.Drawables.pk023);
                case 24: return WatchUi.loadResource(Rez.Drawables.pk024);
                case 25: return WatchUi.loadResource(Rez.Drawables.pk025);
                case 26: return WatchUi.loadResource(Rez.Drawables.pk026);
                case 27: return WatchUi.loadResource(Rez.Drawables.pk027);
                case 28: return WatchUi.loadResource(Rez.Drawables.pk028);
                case 29: return WatchUi.loadResource(Rez.Drawables.pk029);
                case 30: return WatchUi.loadResource(Rez.Drawables.pk030);
                case 31: return WatchUi.loadResource(Rez.Drawables.pk031);
                case 32: return WatchUi.loadResource(Rez.Drawables.pk032);
                case 33: return WatchUi.loadResource(Rez.Drawables.pk033);
                case 34: return WatchUi.loadResource(Rez.Drawables.pk034);
                case 35: return WatchUi.loadResource(Rez.Drawables.pk035);
                case 36: return WatchUi.loadResource(Rez.Drawables.pk036);
                case 37: return WatchUi.loadResource(Rez.Drawables.pk037);
                case 38: return WatchUi.loadResource(Rez.Drawables.pk038);
                case 39: return WatchUi.loadResource(Rez.Drawables.pk039);
                case 40: return WatchUi.loadResource(Rez.Drawables.pk040);
                case 41: return WatchUi.loadResource(Rez.Drawables.pk041);
                case 42: return WatchUi.loadResource(Rez.Drawables.pk042);
                case 43: return WatchUi.loadResource(Rez.Drawables.pk043);
                case 44: return WatchUi.loadResource(Rez.Drawables.pk044);
                case 45: return WatchUi.loadResource(Rez.Drawables.pk045);
                case 46: return WatchUi.loadResource(Rez.Drawables.pk046);
                case 47: return WatchUi.loadResource(Rez.Drawables.pk047);
                case 48: return WatchUi.loadResource(Rez.Drawables.pk048);
                case 49: return WatchUi.loadResource(Rez.Drawables.pk049);
                case 50: return WatchUi.loadResource(Rez.Drawables.pk050);
                case 51: return WatchUi.loadResource(Rez.Drawables.pk051);
                case 52: return WatchUi.loadResource(Rez.Drawables.pk052);
                case 53: return WatchUi.loadResource(Rez.Drawables.pk053);
                case 54: return WatchUi.loadResource(Rez.Drawables.pk054);
                case 55: return WatchUi.loadResource(Rez.Drawables.pk055);
                case 56: return WatchUi.loadResource(Rez.Drawables.pk056);
                case 57: return WatchUi.loadResource(Rez.Drawables.pk057);
                case 58: return WatchUi.loadResource(Rez.Drawables.pk058);
                case 59: return WatchUi.loadResource(Rez.Drawables.pk059);
                case 60: return WatchUi.loadResource(Rez.Drawables.pk060);
                case 61: return WatchUi.loadResource(Rez.Drawables.pk061);
                case 62: return WatchUi.loadResource(Rez.Drawables.pk062);
                case 63: return WatchUi.loadResource(Rez.Drawables.pk063);
                case 64: return WatchUi.loadResource(Rez.Drawables.pk064);
                case 65: return WatchUi.loadResource(Rez.Drawables.pk065);
                case 66: return WatchUi.loadResource(Rez.Drawables.pk066);
                case 67: return WatchUi.loadResource(Rez.Drawables.pk067);
                case 68: return WatchUi.loadResource(Rez.Drawables.pk068);
                case 69: return WatchUi.loadResource(Rez.Drawables.pk069);
                case 70: return WatchUi.loadResource(Rez.Drawables.pk070);
                case 71: return WatchUi.loadResource(Rez.Drawables.pk071);
                case 72: return WatchUi.loadResource(Rez.Drawables.pk072);
                case 73: return WatchUi.loadResource(Rez.Drawables.pk073);
                case 74: return WatchUi.loadResource(Rez.Drawables.pk074);
                case 75: return WatchUi.loadResource(Rez.Drawables.pk075);
                case 76: return WatchUi.loadResource(Rez.Drawables.pk076);
                case 77: return WatchUi.loadResource(Rez.Drawables.pk077);
                case 78: return WatchUi.loadResource(Rez.Drawables.pk078);
                case 79: return WatchUi.loadResource(Rez.Drawables.pk079);
                case 80: return WatchUi.loadResource(Rez.Drawables.pk080);
                case 81: return WatchUi.loadResource(Rez.Drawables.pk081);
                case 82: return WatchUi.loadResource(Rez.Drawables.pk082);
                case 83: return WatchUi.loadResource(Rez.Drawables.pk083);
                case 84: return WatchUi.loadResource(Rez.Drawables.pk084);
                case 85: return WatchUi.loadResource(Rez.Drawables.pk085);
                case 86: return WatchUi.loadResource(Rez.Drawables.pk086);
                case 87: return WatchUi.loadResource(Rez.Drawables.pk087);
                case 88: return WatchUi.loadResource(Rez.Drawables.pk088);
                case 89: return WatchUi.loadResource(Rez.Drawables.pk089);
                case 90: return WatchUi.loadResource(Rez.Drawables.pk090);
                case 91: return WatchUi.loadResource(Rez.Drawables.pk091);
                case 92: return WatchUi.loadResource(Rez.Drawables.pk092);
                case 93: return WatchUi.loadResource(Rez.Drawables.pk093);
                case 94: return WatchUi.loadResource(Rez.Drawables.pk094);
                case 95: return WatchUi.loadResource(Rez.Drawables.pk095);
                case 96: return WatchUi.loadResource(Rez.Drawables.pk096);
                case 97: return WatchUi.loadResource(Rez.Drawables.pk097);
                case 98: return WatchUi.loadResource(Rez.Drawables.pk098);
                case 99: return WatchUi.loadResource(Rez.Drawables.pk099);
                case 100: return WatchUi.loadResource(Rez.Drawables.pk100);
                case 101: return WatchUi.loadResource(Rez.Drawables.pk101);
                case 102: return WatchUi.loadResource(Rez.Drawables.pk102);
                case 103: return WatchUi.loadResource(Rez.Drawables.pk103);
                case 104: return WatchUi.loadResource(Rez.Drawables.pk104);
                case 105: return WatchUi.loadResource(Rez.Drawables.pk105);
                case 106: return WatchUi.loadResource(Rez.Drawables.pk106);
                case 107: return WatchUi.loadResource(Rez.Drawables.pk107);
                case 108: return WatchUi.loadResource(Rez.Drawables.pk108);
                case 109: return WatchUi.loadResource(Rez.Drawables.pk109);
                case 110: return WatchUi.loadResource(Rez.Drawables.pk110);
                case 111: return WatchUi.loadResource(Rez.Drawables.pk111);
                case 112: return WatchUi.loadResource(Rez.Drawables.pk112);
                case 113: return WatchUi.loadResource(Rez.Drawables.pk113);
                case 114: return WatchUi.loadResource(Rez.Drawables.pk114);
                case 115: return WatchUi.loadResource(Rez.Drawables.pk115);
                case 116: return WatchUi.loadResource(Rez.Drawables.pk116);
                case 117: return WatchUi.loadResource(Rez.Drawables.pk117);
                case 118: return WatchUi.loadResource(Rez.Drawables.pk118);
                case 119: return WatchUi.loadResource(Rez.Drawables.pk119);
                case 120: return WatchUi.loadResource(Rez.Drawables.pk120);
                case 121: return WatchUi.loadResource(Rez.Drawables.pk121);
                case 122: return WatchUi.loadResource(Rez.Drawables.pk122);
                case 123: return WatchUi.loadResource(Rez.Drawables.pk123);
                case 124: return WatchUi.loadResource(Rez.Drawables.pk124);
                case 125: return WatchUi.loadResource(Rez.Drawables.pk125);
                case 126: return WatchUi.loadResource(Rez.Drawables.pk126);
                case 127: return WatchUi.loadResource(Rez.Drawables.pk127);
                case 128: return WatchUi.loadResource(Rez.Drawables.pk128);
                case 129: return WatchUi.loadResource(Rez.Drawables.pk129);
                case 130: return WatchUi.loadResource(Rez.Drawables.pk130);
                case 131: return WatchUi.loadResource(Rez.Drawables.pk131);
                case 132: return WatchUi.loadResource(Rez.Drawables.pk132);
                case 133: return WatchUi.loadResource(Rez.Drawables.pk133);
                case 134: return WatchUi.loadResource(Rez.Drawables.pk134);
                case 135: return WatchUi.loadResource(Rez.Drawables.pk135);
                case 136: return WatchUi.loadResource(Rez.Drawables.pk136);
                case 137: return WatchUi.loadResource(Rez.Drawables.pk137);
                case 138: return WatchUi.loadResource(Rez.Drawables.pk138);
                case 139: return WatchUi.loadResource(Rez.Drawables.pk139);
                case 140: return WatchUi.loadResource(Rez.Drawables.pk140);
                case 141: return WatchUi.loadResource(Rez.Drawables.pk141);
                case 142: return WatchUi.loadResource(Rez.Drawables.pk142);
                case 143: return WatchUi.loadResource(Rez.Drawables.pk143);
                case 144: return WatchUi.loadResource(Rez.Drawables.pk144);
                case 145: return WatchUi.loadResource(Rez.Drawables.pk145);
                case 146: return WatchUi.loadResource(Rez.Drawables.pk146);
                case 147: return WatchUi.loadResource(Rez.Drawables.pk147);
                case 148: return WatchUi.loadResource(Rez.Drawables.pk148);
                case 149: return WatchUi.loadResource(Rez.Drawables.pk149);
                case 150: return WatchUi.loadResource(Rez.Drawables.pk150);
                case 151: return WatchUi.loadResource(Rez.Drawables.pk151);
            }
        } catch (e) {
            System.println("Error cargando sprite " + spriteName);
        }
        
        return null;
    }

    static function formatId(id as Lang.Number) as Lang.String {
        if (id < 10) { return "00" + id.toString(); }
        if (id < 100) { return "0" + id.toString(); }
        return id.toString();
    }
}
