"""
Generate Game Boy Color-style backgrounds for PokeWatch using REAL
Pokémon Crystal tileset art from pret/pokecrystal (GitHub).
Downloads tileset PNG, colorizes with authentic GBC palettes,
and composes route/battle backgrounds.

Designed for 390x390 round AMOLED display.
Output: RGB PNG with black outside the circle.
"""
from PIL import Image, ImageDraw
import urllib.request
import io
import math
import random
import os

W, H = 390, 390
CX, CY = W // 2, H // 2
RADIUS = W // 2

# Scale: each 8x8 game tile becomes SCALE*8 pixels on screen
SCALE = 6  # 8*6 = 48px per tile => ~8 tiles across 390px
TILE = 8   # original tile size

random.seed(42)

# Dimming factor for AMOLED
DIM = 0.45

# ── Tileset URLs from pret/pokecrystal ──────────────────────
TILESET_URLS = {
    "johto": "https://raw.githubusercontent.com/pret/pokecrystal/master/gfx/tilesets/johto.png",
    "forest": "https://raw.githubusercontent.com/pret/pokecrystal/master/gfx/tilesets/forest.png",
    "cave": "https://raw.githubusercontent.com/pret/pokecrystal/master/gfx/tilesets/cave.png",
    "park": "https://raw.githubusercontent.com/pret/pokecrystal/master/gfx/tilesets/park.png",
}

# ── GBC Color Palettes (authentic Pokémon Crystal) ──────────
# Each palette maps grayscale 255→170→85→0 to 4 colors
PALETTES = {
    # Outdoor/Route palettes
    "sky_day":     ((168, 216, 248), (104, 168, 224), (56, 104, 168), (24, 48, 80)),
    "sky_night":   ((24, 32, 56),    (16, 20, 40),    (8, 12, 28),    (4, 4, 16)),
    "sky_sunset":  ((248, 168, 104), (200, 104, 56),  (136, 56, 32),  (64, 24, 16)),
    "sky_morning": ((200, 184, 248), (152, 136, 200), (96, 80, 144),  (40, 32, 72)),
    "grass":       ((120, 208, 80),  (72, 160, 48),   (40, 112, 24),  (16, 56, 12)),
    "grass_night": ((32, 64, 24),    (20, 48, 16),    (12, 32, 8),    (4, 16, 4)),
    "grass_sunset":((144, 168, 72),  (96, 120, 40),   (56, 72, 24),   (24, 32, 12)),
    "grass_morn":  ((128, 200, 96),  (80, 152, 56),   (48, 104, 32),  (16, 48, 12)),
    "trees":       ((88, 176, 56),   (48, 128, 32),   (24, 80, 16),   (8, 40, 8)),
    "trees_night": ((20, 48, 16),    (12, 32, 8),     (8, 20, 4),     (4, 8, 4)),
    "trees_sunset":((104, 128, 48),  (64, 88, 28),    (36, 52, 16),   (16, 24, 8)),
    "trees_morn":  ((96, 168, 64),   (56, 120, 40),   (28, 72, 20),   (8, 32, 8)),
    "path":        ((232, 200, 128), (184, 144, 80),  (128, 96, 48),  (64, 40, 16)),
    "path_night":  ((48, 40, 24),    (36, 28, 16),    (24, 16, 8),    (12, 8, 4)),
    "path_sunset": ((200, 152, 88),  (152, 104, 56),  (96, 64, 32),   (48, 28, 12)),
    "path_morn":   ((216, 192, 136), (168, 136, 88),  (112, 88, 48),  (56, 36, 16)),
    "water":       ((128, 200, 248), (72, 144, 224),  (32, 88, 176),  (8, 40, 96)),
    "battle_ground": ((160, 176, 120), (112, 128, 80), (72, 80, 48),  (32, 40, 20)),
    "battle_sky":  ((48, 56, 72),    (32, 40, 56),    (20, 24, 40),   (8, 12, 20)),
}

# Cache for downloaded tilesets
_tileset_cache = {}


def download_tileset(name):
    """Download a tileset PNG from pret/pokecrystal."""
    if name in _tileset_cache:
        return _tileset_cache[name]

    cache_path = os.path.join(os.path.dirname(__file__), f"temp_{name}.png")
    if os.path.exists(cache_path):
        img = Image.open(cache_path).convert("L")
        _tileset_cache[name] = img
        return img

    url = TILESET_URLS[name]
    print(f"  Downloading tileset '{name}' from pret/pokecrystal...")
    req = urllib.request.Request(url, headers={"User-Agent": "PokeWatch/1.0"})
    with urllib.request.urlopen(req, timeout=15) as response:
        data = response.read()
        img = Image.open(io.BytesIO(data)).convert("L")
        img.save(cache_path)
        _tileset_cache[name] = img
        return img


def get_tile(tileset, tx, ty):
    """Extract a single 8x8 tile from a tileset."""
    return tileset.crop((tx * TILE, ty * TILE, tx * TILE + TILE, ty * TILE + TILE))


def colorize_tile(tile, palette):
    """Colorize a grayscale tile using a 4-color GBC palette."""
    result = Image.new("RGB", tile.size)
    pixels = list(tile.getdata())
    # Map: 255→palette[0], 170→[1], 85→[2], 0→[3]
    gray_map = {255: palette[0], 170: palette[1], 85: palette[2], 0: palette[3]}
    new_pixels = []
    for p in pixels:
        # Find closest gray value
        closest = min(gray_map.keys(), key=lambda g: abs(g - p))
        new_pixels.append(gray_map[closest])
    result.putdata(new_pixels)
    return result


def dim_image(img, factor=DIM):
    """Reduce brightness of entire image for AMOLED."""
    pixels = list(img.getdata())
    dimmed = [tuple(max(0, min(255, int(c * factor))) for c in p) for p in pixels]
    result = Image.new("RGB", img.size)
    result.putdata(dimmed)
    return result


def circle_mask_solid(img):
    """Apply circular mask — black outside circle, no transparency."""
    result = Image.new("RGB", (W, H), (0, 0, 0))
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    margin = 1
    d.ellipse([margin, margin, W - 1 - margin, H - 1 - margin], fill=255)
    result.paste(img.convert("RGB"), mask=mask)
    return result


def compose_scene(tile_map, tileset, scene_width, scene_height):
    """
    Compose a scene from a tile_map.
    tile_map: list of (tile_x, tile_y, palette_name, dst_x, dst_y) entries,
              or (region, palette_name, dst_x, dst_y) for tile regions.
    Returns a small-resolution image at tile scale.
    """
    scene = Image.new("RGB", (scene_width * TILE, scene_height * TILE), (0, 0, 0))
    for entry in tile_map:
        src_tx, src_ty, pal_name, dst_tx, dst_ty = entry
        palette = PALETTES[pal_name]
        tile = get_tile(tileset, src_tx, src_ty)
        colored = colorize_tile(tile, palette)
        scene.paste(colored, (dst_tx * TILE, dst_ty * TILE))
    return scene


def fill_zone_with_tiles(tileset, palette_name, tile_coords, zone_x, zone_y, zone_w, zone_h):
    """
    Generate tile_map entries to fill a zone by repeating tiles from tile_coords.
    tile_coords: list of (tx, ty) tile positions from the tileset
    """
    entries = []
    palette = PALETTES[palette_name]
    idx = 0
    for dy in range(zone_h):
        for dx in range(zone_w):
            tx, ty = tile_coords[idx % len(tile_coords)]
            entries.append((tx, ty, palette_name, zone_x + dx, zone_y + dy))
            idx += 1
    return entries


def build_route_scene(sky_pal, trees_pal, grass_pal, path_pal):
    """
    Build a route background using real Pokémon Crystal tiles.
    Downloads the johto tileset, colorizes tiles for each zone,
    and composes a route scene.
    """
    tileset = download_tileset("johto")

    # Scene grid: 9 tiles wide × 9 tiles tall (72×72 px → scaled to 390)
    SW, SH = 9, 9

    # ── Identify tiles from the johto tileset ──────────────
    # Row 0, cols 0-5: edge/transition tiles (good for sky gradient)
    # Row 2, cols 0-6: ground detail tiles (good for grass)
    # Row 4-5, cols 6-9: dense tiles (good for trees/canopy)
    # Row 0-1, cols 7-9: medium tiles (good for path)
    # Row 3, cols 0-6: mixed tiles (flower/grass details)

    # Sky zone tiles (sparse, for subtle sky texture)
    sky_tiles = [(0, 0), (6, 0), (0, 10), (6, 10)]
    # Tree canopy tiles (dense, rich texture)
    tree_tiles = [(10, 0), (11, 0), (14, 0), (15, 0),
                  (0, 1), (1, 1), (2, 1), (3, 1),
                  (4, 1), (5, 1)]
    # Tree trunk tiles
    trunk_tiles = [(7, 2), (8, 2), (9, 2), (10, 2)]
    # Grass tiles (medium detail)
    grass_tiles = [(0, 2), (1, 2), (2, 2), (3, 2),
                   (4, 2), (5, 2), (6, 2),
                   (0, 3), (1, 3), (2, 3), (3, 3)]
    # Path tiles (medium-sparse)
    path_tiles_src = [(7, 0), (8, 0), (9, 0),
                      (7, 3), (8, 3), (9, 3)]
    # Tall grass detail tiles
    tall_grass_tiles = [(4, 3), (5, 3), (6, 3),
                        (11, 2), (12, 2)]

    tile_map = []

    # --- Sky zone (rows 0-1) ---
    tile_map += fill_zone_with_tiles(tileset, sky_pal, sky_tiles, 0, 0, SW, 2)

    # --- Distant hills / tree canopy (rows 2-3) ---
    tile_map += fill_zone_with_tiles(tileset, trees_pal, tree_tiles, 0, 2, SW, 2)

    # --- Tree trunks + transition (row 4) ---
    tile_map += fill_zone_with_tiles(tileset, trees_pal, trunk_tiles, 0, 4, SW, 1)

    # --- Grass field (rows 5-7) with path in middle ---
    for dy in range(3):
        for dx in range(SW):
            # Center 3 columns = path, rest = grass
            if 3 <= dx <= 5:
                # Path
                tx, ty = path_tiles_src[(dy * 3 + dx) % len(path_tiles_src)]
                tile_map.append((tx, ty, path_pal, dx, 5 + dy))
            else:
                # Grass with occasional tall grass
                if random.random() < 0.3:
                    tx, ty = tall_grass_tiles[(dy * SW + dx) % len(tall_grass_tiles)]
                else:
                    tx, ty = grass_tiles[(dy * SW + dx) % len(grass_tiles)]
                tile_map.append((tx, ty, grass_pal, dx, 5 + dy))

    # --- Bottom grass (row 8) with wider path ---
    for dx in range(SW):
        if 2 <= dx <= 6:
            tx, ty = path_tiles_src[(dx + 5) % len(path_tiles_src)]
            tile_map.append((tx, ty, path_pal, dx, 8))
        else:
            tx, ty = grass_tiles[(dx + 7) % len(grass_tiles)]
            tile_map.append((tx, ty, grass_pal, dx, 8))

    # Compose the small scene
    scene = compose_scene(tile_map, tileset, SW, SH)

    # Scale up to target size with NEAREST for pixel art look
    scaled = scene.resize((W, H), Image.NEAREST)

    # Dim for AMOLED
    dimmed = dim_image(scaled)

    return circle_mask_solid(dimmed)


def generate_route_day():
    """Route background - daytime."""
    return build_route_scene("sky_day", "trees", "grass", "path")


def generate_route_night():
    """Route background - nighttime."""
    return build_route_scene("sky_night", "trees_night", "grass_night", "path_night")


def generate_route_sunset():
    """Route background - sunset."""
    return build_route_scene("sky_sunset", "trees_sunset", "grass_sunset", "path_sunset")


def generate_morning_route():
    """Route background - morning."""
    return build_route_scene("sky_morning", "trees_morn", "grass_morn", "path_morn")


def generate_battle_bg():
    """Battle/encounter background using real game tiles."""
    tileset = download_tileset("johto")

    SW, SH = 9, 9

    # Battle scene: dark sky at top, battle ground at bottom
    # with a clear platform area in the middle

    # Sky tiles (sparse for dark battle sky)
    sky_tiles = [(0, 0), (6, 0), (0, 10), (6, 10)]
    # Ground tiles (for battle arena floor)
    ground_tiles = [(0, 2), (1, 2), (2, 2), (3, 2),
                    (4, 2), (5, 2), (6, 2)]
    # Dense tiles for arena walls/bushes
    wall_tiles = [(10, 0), (11, 0), (14, 0), (15, 0),
                  (0, 1), (1, 1)]
    # Platform tiles
    plat_tiles = [(7, 0), (8, 0), (9, 0),
                  (7, 3), (8, 3), (9, 3)]

    tile_map = []

    # --- Dark sky (rows 0-3) ---
    tile_map += fill_zone_with_tiles(tileset, "battle_sky", sky_tiles, 0, 0, SW, 4)

    # --- Horizon / bushes (row 4) ---
    tile_map += fill_zone_with_tiles(tileset, "trees", wall_tiles, 0, 4, SW, 1)

    # --- Battle ground (rows 5-6) with platform ---
    for dy in range(2):
        for dx in range(SW):
            if 2 <= dx <= 6:
                # Platform area
                tx, ty = plat_tiles[(dy * SW + dx) % len(plat_tiles)]
                tile_map.append((tx, ty, "battle_ground", dx, 5 + dy))
            else:
                # Side ground
                tx, ty = ground_tiles[(dy * SW + dx) % len(ground_tiles)]
                tile_map.append((tx, ty, "grass", dx, 5 + dy))

    # --- Bottom ground (rows 7-8) ---
    tile_map += fill_zone_with_tiles(tileset, "battle_ground", ground_tiles, 0, 7, SW, 2)

    scene = compose_scene(tile_map, tileset, SW, SH)
    scaled = scene.resize((W, H), Image.NEAREST)
    dimmed = dim_image(scaled)

    return circle_mask_solid(dimmed)


if __name__ == "__main__":
    out_dir = "resources/drawables"

    print("Downloading tilesets from pret/pokecrystal...")
    download_tileset("johto")
    print()

    print("Generating bg_route_day.png...")
    generate_route_day().save(f"{out_dir}/bg_route_day.png")

    print("Generating bg_route_night.png...")
    generate_route_night().save(f"{out_dir}/bg_route_night.png")

    print("Generating bg_route_sunset.png...")
    generate_route_sunset().save(f"{out_dir}/bg_route_sunset.png")

    print("Generating bg_route_morning.png...")
    generate_morning_route().save(f"{out_dir}/bg_route_morning.png")

    print("Generating bg_battle.png...")
    generate_battle_bg().save(f"{out_dir}/bg_battle.png")

    print("Done! Generated 5 backgrounds using real Pokémon Crystal tiles.")
