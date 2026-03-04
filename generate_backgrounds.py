"""
Generate Game Boy Color-style backgrounds for PokeWatch.

Draws proper pixel-art scenes from scratch using PIL:
  - Route backgrounds (day/night/sunset/morning) with sky, trees, grass, path
  - Battle background with terrain platform (like Pokémon Crystal)

Designed for 390x390 round AMOLED display.
Output: RGB PNG with black outside the circle.
"""
from PIL import Image, ImageDraw
import math
import random
import os

W, H = 390, 390
CX, CY = W // 2, H // 2
RADIUS = W // 2

# Pixel scale: each "game pixel" becomes SCALE real pixels
SCALE = 3

# Dimming factor for AMOLED readability
DIM = 0.40

random.seed(42)


# ── Color Palettes ─────────────────────────────────────────
PALETTES = {
    "day": {
        "sky_top":      (104, 184, 248),
        "sky_mid":      (144, 208, 248),
        "sky_bottom":   (184, 224, 248),
        "cloud":        (232, 240, 248),
        "cloud_shadow": (168, 208, 240),
        "tree_canopy":  (32, 128, 48),
        "tree_canopy2": (48, 152, 56),
        "tree_trunk":   (96, 72, 48),
        "tree_trunk2":  (120, 88, 56),
        "grass":        (72, 184, 64),
        "grass2":       (56, 160, 48),
        "grass_dark":   (40, 128, 32),
        "tall_grass":   (48, 168, 40),
        "path":         (200, 176, 128),
        "path2":        (184, 160, 112),
        "path_edge":    (160, 136, 96),
        "hill":         (72, 144, 64),
        "hill2":        (56, 120, 48),
        "flowers":      (248, 200, 80),
        "flowers2":     (248, 120, 96),
        "water":        (80, 152, 240),
    },
    "night": {
        "sky_top":      (8, 12, 32),
        "sky_mid":      (12, 16, 40),
        "sky_bottom":   (16, 24, 48),
        "cloud":        (24, 32, 56),
        "cloud_shadow": (16, 24, 44),
        "tree_canopy":  (12, 40, 20),
        "tree_canopy2": (16, 52, 24),
        "tree_trunk":   (32, 24, 16),
        "tree_trunk2":  (40, 32, 20),
        "grass":        (20, 56, 20),
        "grass2":       (16, 48, 16),
        "grass_dark":   (12, 36, 12),
        "tall_grass":   (16, 52, 16),
        "path":         (56, 48, 36),
        "path2":        (48, 40, 28),
        "path_edge":    (40, 32, 24),
        "hill":         (16, 44, 20),
        "hill2":        (12, 36, 16),
        "flowers":      (64, 56, 24),
        "flowers2":     (64, 32, 28),
        "water":        (16, 32, 72),
        "star":         (200, 208, 240),
        "star2":        (160, 168, 200),
    },
    "sunset": {
        "sky_top":      (64, 32, 80),
        "sky_mid":      (168, 72, 48),
        "sky_bottom":   (240, 136, 56),
        "cloud":        (248, 176, 104),
        "cloud_shadow": (200, 120, 64),
        "tree_canopy":  (48, 88, 32),
        "tree_canopy2": (64, 104, 40),
        "tree_trunk":   (80, 56, 32),
        "tree_trunk2":  (96, 64, 40),
        "grass":        (88, 128, 48),
        "grass2":       (72, 112, 40),
        "grass_dark":   (56, 88, 32),
        "tall_grass":   (80, 120, 40),
        "path":         (176, 136, 88),
        "path2":        (160, 120, 72),
        "path_edge":    (136, 100, 60),
        "hill":         (64, 96, 40),
        "hill2":        (48, 80, 32),
        "flowers":      (200, 152, 56),
        "flowers2":     (200, 96, 72),
        "water":        (120, 96, 152),
    },
    "morning": {
        "sky_top":      (160, 136, 200),
        "sky_mid":      (192, 168, 224),
        "sky_bottom":   (216, 200, 240),
        "cloud":        (232, 224, 248),
        "cloud_shadow": (200, 184, 224),
        "tree_canopy":  (40, 120, 48),
        "tree_canopy2": (56, 144, 56),
        "tree_trunk":   (88, 64, 40),
        "tree_trunk2":  (104, 80, 48),
        "grass":        (80, 176, 72),
        "grass2":       (64, 152, 56),
        "grass_dark":   (48, 120, 40),
        "tall_grass":   (72, 168, 56),
        "path":         (192, 176, 136),
        "path2":        (176, 156, 116),
        "path_edge":    (152, 132, 100),
        "hill":         (64, 136, 56),
        "hill2":        (48, 112, 44),
        "flowers":      (240, 192, 96),
        "flowers2":     (240, 136, 112),
        "water":        (120, 160, 224),
    },
}

BATTLE_PAL = {
    # Sky gradient (dusk/twilight feel like Pokémon Crystal wild battles)
    "sky_top":       (16, 20, 48),
    "sky_mid":       (32, 40, 72),
    "sky_bottom":    (56, 64, 96),
    "sky_glow":      (80, 72, 104),
    # Distant mountains
    "mountain":      (40, 48, 72),
    "mountain2":     (48, 56, 80),
    "mountain_snow": (72, 80, 104),
    # Distant trees (horizon)
    "far_tree":      (24, 56, 32),
    "far_tree2":     (32, 64, 40),
    # Ground terrain
    "ground":        (88, 104, 64),
    "ground2":       (72, 88, 52),
    "ground_dark":   (56, 68, 40),
    "ground_far":    (64, 80, 52),
    # Details
    "grass_tuft":    (64, 128, 48),
    "grass_tuft2":   (48, 104, 36),
    "grass_tuft3":   (80, 144, 56),
    "rock":          (96, 92, 80),
    "rock2":         (80, 76, 64),
    "rock_hi":       (112, 108, 96),
    "dust":          (120, 112, 88),
}


def dim_pixel(color, factor=DIM):
    return tuple(max(0, min(255, int(c * factor))) for c in color)


def circle_mask(img):
    """Apply circular mask — black outside circle."""
    result = Image.new("RGB", (W, H), (0, 0, 0))
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse([1, 1, W - 2, H - 2], fill=255)
    result.paste(img.convert("RGB"), mask=mask)
    return result


def draw_pixel_rect(draw, x, y, w, h, color, scale=SCALE):
    """Draw a scaled pixel rectangle."""
    draw.rectangle(
        [x * scale, y * scale, (x + w) * scale - 1, (y + h) * scale - 1],
        fill=dim_pixel(color)
    )


def draw_cloud(draw, cx, cy, pal, scale=SCALE):
    """Draw a simple pixel-art cloud."""
    c = pal["cloud"]
    cs = pal["cloud_shadow"]
    # Main body (3 blobs merged)
    draw_pixel_rect(draw, cx - 4, cy, 8, 2, c, scale)
    draw_pixel_rect(draw, cx - 6, cy + 1, 12, 2, c, scale)
    draw_pixel_rect(draw, cx - 5, cy + 2, 10, 1, cs, scale)
    # Left bump
    draw_pixel_rect(draw, cx - 5, cy - 1, 4, 2, c, scale)
    # Right bump
    draw_pixel_rect(draw, cx + 1, cy - 2, 5, 3, c, scale)
    # Center bump
    draw_pixel_rect(draw, cx - 2, cy - 2, 4, 2, c, scale)


def draw_star(draw, x, y, color, scale=SCALE):
    """Draw a tiny star (1 pixel)."""
    draw_pixel_rect(draw, x, y, 1, 1, color, scale)


def draw_tree(draw, tx, ty, pal, variant=0, scale=SCALE):
    """Draw a pixel-art tree (canopy + trunk)."""
    c1 = pal["tree_canopy"]
    c2 = pal["tree_canopy2"]
    t1 = pal["tree_trunk"]
    t2 = pal["tree_trunk2"]

    if variant == 0:
        # Round leafy tree
        draw_pixel_rect(draw, tx - 2, ty - 6, 5, 2, c1, scale)
        draw_pixel_rect(draw, tx - 3, ty - 4, 7, 3, c1, scale)
        draw_pixel_rect(draw, tx - 2, ty - 5, 3, 2, c2, scale)
        draw_pixel_rect(draw, tx - 3, ty - 1, 7, 1, c2, scale)
        # Trunk
        draw_pixel_rect(draw, tx, ty, 1, 3, t1, scale)
        draw_pixel_rect(draw, tx - 1, ty + 2, 1, 1, t2, scale)
    elif variant == 1:
        # Pine / conifer tree
        draw_pixel_rect(draw, tx, ty - 7, 1, 1, c2, scale)
        draw_pixel_rect(draw, tx - 1, ty - 6, 3, 1, c1, scale)
        draw_pixel_rect(draw, tx - 2, ty - 5, 5, 1, c1, scale)
        draw_pixel_rect(draw, tx - 1, ty - 4, 3, 1, c2, scale)
        draw_pixel_rect(draw, tx - 3, ty - 3, 7, 1, c1, scale)
        draw_pixel_rect(draw, tx - 2, ty - 2, 5, 1, c1, scale)
        draw_pixel_rect(draw, tx - 4, ty - 1, 9, 2, c1, scale)
        draw_pixel_rect(draw, tx - 3, ty, 7, 1, c2, scale)
        # Trunk
        draw_pixel_rect(draw, tx, ty + 1, 1, 2, t1, scale)
    else:
        # Bush / shrub
        draw_pixel_rect(draw, tx - 2, ty - 3, 5, 1, c2, scale)
        draw_pixel_rect(draw, tx - 3, ty - 2, 7, 2, c1, scale)
        draw_pixel_rect(draw, tx - 2, ty - 1, 5, 1, c2, scale)
        draw_pixel_rect(draw, tx - 3, ty, 7, 1, c1, scale)
        # Trunk
        draw_pixel_rect(draw, tx, ty + 1, 1, 1, t1, scale)


def draw_grass_detail(draw, x, y, pal, scale=SCALE):
    """Draw grass texture blades."""
    gd = pal["grass_dark"]
    tg = pal["tall_grass"]
    draw_pixel_rect(draw, x, y, 1, 1, gd, scale)
    if random.random() < 0.5:
        draw_pixel_rect(draw, x, y - 1, 1, 1, tg, scale)


def draw_flower(draw, x, y, pal, scale=SCALE):
    """Draw a small flower dot."""
    c = pal["flowers"] if random.random() > 0.5 else pal["flowers2"]
    draw_pixel_rect(draw, x, y, 1, 1, c, scale)


def generate_route(pal_name):
    """Generate a route background with proper composition."""
    pal = PALETTES[pal_name]
    pw = W // SCALE  # pixel width in game pixels (~130)
    ph = H // SCALE  # pixel height (~130)

    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── 1. Sky gradient (top ~35%) ─────────────────────────
    sky_h = int(ph * 0.35)
    for y in range(sky_h):
        frac = y / max(1, sky_h - 1)
        if frac < 0.5:
            t = frac * 2
            color = tuple(int(pal["sky_top"][i] * (1 - t) + pal["sky_mid"][i] * t) for i in range(3))
        else:
            t = (frac - 0.5) * 2
            color = tuple(int(pal["sky_mid"][i] * (1 - t) + pal["sky_bottom"][i] * t) for i in range(3))
        draw_pixel_rect(draw, 0, y, pw, 1, color)

    # Clouds or stars
    if pal_name != "night":
        draw_cloud(draw, 20, 8, pal)
        draw_cloud(draw, 75, 5, pal)
        draw_cloud(draw, 110, 12, pal)
        draw_cloud(draw, 50, 18, pal)
    else:
        # Stars
        star_positions = [
            (10, 3), (25, 8), (45, 2), (60, 10), (80, 5),
            (95, 12), (110, 4), (120, 9), (15, 15), (70, 7),
            (35, 14), (100, 3), (55, 6), (88, 14), (42, 11),
            (105, 8), (18, 6), (65, 13), (82, 2), (115, 11),
        ]
        for sx, sy in star_positions:
            c = pal["star"] if random.random() > 0.4 else pal["star2"]
            draw_star(draw, sx, sy, c)

    # ── 2. Distant hills (~28-42%) ─────────────────────────
    hill_y = int(ph * 0.28)
    hill_depth = 14
    for x in range(pw):
        phase1 = x * math.pi * 2 / pw
        phase2 = x * math.pi * 4 / pw
        hill_top = hill_y + int(4 * math.sin(phase1 + 0.8) + 2 * math.sin(phase2 + 2.1))
        for y in range(hill_top, hill_y + hill_depth):
            c = pal["hill"] if ((x + y) % 3 != 0) else pal["hill2"]
            draw_pixel_rect(draw, x, y, 1, 1, c)

    # ── 3. Tree line (~38-50%) ─────────────────────────────
    tree_base = int(ph * 0.42)
    grass_start = int(ph * 0.48)

    # Dense canopy fill behind trees — extends down to grass_start (no gap)
    canopy_top = tree_base - 8
    canopy_bot = grass_start
    for y in range(canopy_top, canopy_bot):
        for x in range(pw):
            if y < tree_base - 4:
                c = pal["tree_canopy"] if (x + y) % 2 == 0 else pal["tree_canopy2"]
            else:
                c = pal["tree_canopy2"] if (x + y) % 3 == 0 else pal["tree_canopy"]
            draw_pixel_rect(draw, x, y, 1, 1, c)

    # Individual trees on top of canopy
    tree_positions = [5, 15, 22, 33, 42, 50, 58, 68, 78, 85, 95, 105, 115, 125]
    for i, tx in enumerate(tree_positions):
        if tx < pw:
            draw_tree(draw, tx, tree_base - 2, pal, variant=i % 3)

    # ── 4. Grass field + path (~48-85%) ────────────────────
    grass_end = int(ph * 0.85)
    path_center = pw // 2
    path_half = 6  # half-width of path

    for y in range(grass_start, grass_end):
        # Slight path curve
        curve = int(3 * math.sin((y - grass_start) * math.pi / 40))
        pc = path_center + curve

        for x in range(pw):
            dist_from_path = abs(x - pc)
            if dist_from_path <= path_half:
                # Path
                if dist_from_path >= path_half:
                    c = pal["path_edge"]
                elif (x + y) % 3 == 0:
                    c = pal["path2"]
                else:
                    c = pal["path"]
            else:
                # Grass
                if (x + y) % 4 == 0:
                    c = pal["grass2"]
                elif (x * 3 + y * 7) % 11 == 0:
                    c = pal["grass_dark"]
                else:
                    c = pal["grass"]
            draw_pixel_rect(draw, x, y, 1, 1, c)

    # Grass details and flowers on the field
    for y in range(grass_start + 2, grass_end, 4):
        for x in range(0, pw, 5):
            curve = int(3 * math.sin((y - grass_start) * math.pi / 40))
            pc = path_center + curve
            if abs(x - pc) > path_half + 2:
                draw_grass_detail(draw, x + random.randint(-1, 1), y, pal)
                if random.random() < 0.12:
                    draw_flower(draw, x + random.randint(0, 2), y, pal)

    # ── 5. Foreground (~85-100%) ───────────────────────────
    fg_start = int(ph * 0.85)
    for y in range(fg_start, ph):
        curve = int(3 * math.sin((y - grass_start) * math.pi / 40))
        pc = path_center + curve

        for x in range(pw):
            if abs(x - pc) <= path_half + 1:
                dist_from_path = abs(x - pc)
                if dist_from_path >= path_half:
                    c = pal["path_edge"]
                elif (x + y) % 3 == 0:
                    c = pal["path2"]
                else:
                    c = pal["path"]
            else:
                if (x + y) % 3 == 0:
                    c = pal["grass_dark"]
                elif (x + y) % 5 == 0:
                    c = pal["grass2"]
                else:
                    c = pal["grass"]
            draw_pixel_rect(draw, x, y, 1, 1, c)

    return circle_mask(img)


def generate_battle():
    """Generate a battle background like GBA Pokémon — landscape only,
    no platforms. Sky, distant mountains, tree silhouettes, and natural
    grassy terrain where Pokémon just stand on the ground."""
    pal = BATTLE_PAL
    pw = W // SCALE
    ph = H // SCALE

    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── 1. Atmospheric sky gradient (top ~42%) ─────────────
    sky_end = int(ph * 0.42)
    for y in range(sky_end):
        frac = y / max(1, sky_end - 1)
        if frac < 0.4:
            t = frac / 0.4
            color = tuple(int(pal["sky_top"][i] * (1 - t) + pal["sky_mid"][i] * t) for i in range(3))
        elif frac < 0.8:
            t = (frac - 0.4) / 0.4
            color = tuple(int(pal["sky_mid"][i] * (1 - t) + pal["sky_bottom"][i] * t) for i in range(3))
        else:
            t = (frac - 0.8) / 0.2
            color = tuple(int(pal["sky_bottom"][i] * (1 - t) + pal["sky_glow"][i] * t) for i in range(3))
        draw_pixel_rect(draw, 0, y, pw, 1, color)

    # ── 2. Distant mountains silhouette ────────────────────
    mtn_base = int(ph * 0.32)
    for x in range(pw):
        # Peak 1: wide, left of center
        p1x = pw * 0.3
        p1h = 18
        d1 = abs(x - p1x)
        h1 = max(0, p1h - int(d1 * 0.45)) if d1 < p1h / 0.45 else 0
        # Sub-peak on shoulder
        sp1x = pw * 0.18
        sp1h = 10
        sd1 = abs(x - sp1x)
        sh1 = max(0, sp1h - int(sd1 * 0.5)) if sd1 < sp1h / 0.5 else 0

        # Peak 2: narrower, right of center
        p2x = pw * 0.72
        p2h = 14
        d2 = abs(x - p2x)
        h2 = max(0, p2h - int(d2 * 0.55)) if d2 < p2h / 0.55 else 0
        # Sub-peak
        sp2x = pw * 0.85
        sp2h = 8
        sd2 = abs(x - sp2x)
        sh2 = max(0, sp2h - int(sd2 * 0.4)) if sd2 < sp2h / 0.4 else 0

        peak = max(h1, h2, sh1, sh2)
        for dy in range(peak):
            y = mtn_base - dy
            if 0 <= y < ph:
                if dy > peak - 3 and peak > 10:
                    c = pal["mountain_snow"]
                elif (x + dy) % 3 == 0:
                    c = pal["mountain2"]
                else:
                    c = pal["mountain"]
                draw_pixel_rect(draw, x, y, 1, 1, c)

    # ── 3. Distant tree line (horizon) ─────────────────────
    tree_y = int(ph * 0.38)
    ground_start = int(ph * 0.42)
    for x in range(pw):
        th = 3 + int(2 * math.sin(x * 0.8) + 1.5 * math.sin(x * 1.7 + 0.5))
        th = max(2, min(6, th))
        for dy in range(th):
            y = tree_y - dy
            if 0 <= y < ph:
                c = pal["far_tree"] if (x + dy) % 2 == 0 else pal["far_tree2"]
                draw_pixel_rect(draw, x, y, 1, 1, c)
        # Fill down to ground_start to avoid gap
        for dy in range(ground_start - tree_y):
            c = pal["far_tree"] if (x + dy) % 3 == 0 else pal["far_tree2"]
            draw_pixel_rect(draw, x, tree_y + dy, 1, 1, c)

    # ── 4. Natural ground terrain ──────────────────────────
    for y in range(ground_start, ph):
        depth_frac = (y - ground_start) / max(1, ph - ground_start - 1)
        for x in range(pw):
            if depth_frac < 0.15:
                c = pal["ground_far"]
            elif (x + y) % 5 == 0:
                c = pal["ground_dark"]
            elif (x * 3 + y * 7) % 11 == 0:
                c = pal["ground2"]
            else:
                c = pal["ground"]
            bright = 0.85 + 0.15 * depth_frac
            c = tuple(min(255, int(ci * bright)) for ci in c)
            draw_pixel_rect(draw, x, y, 1, 1, c)

    # Scattered rocks on the ground
    rock_positions = [
        (12, ground_start + 8), (28, ground_start + 14),
        (95, ground_start + 10), (108, ground_start + 20),
        (45, ground_start + 25), (75, ground_start + 18),
        (18, ground_start + 35), (115, ground_start + 30),
        (55, ground_start + 40), (88, ground_start + 45),
    ]
    for rx, ry in rock_positions:
        if rx < pw and ry < ph:
            draw_pixel_rect(draw, rx, ry, 2, 1, pal["rock"])
            draw_pixel_rect(draw, rx, ry - 1, 2, 1, pal["rock_hi"])
            draw_pixel_rect(draw, rx + 1, ry + 1, 1, 1, pal["rock2"])

    # Grass tufts scattered across terrain
    tuft_positions = [
        (8, ground_start + 5), (22, ground_start + 12),
        (40, ground_start + 6), (62, ground_start + 15),
        (80, ground_start + 8), (100, ground_start + 22),
        (35, ground_start + 30), (70, ground_start + 35),
        (110, ground_start + 12), (50, ground_start + 20),
        (15, ground_start + 28), (90, ground_start + 38),
        (25, ground_start + 42), (105, ground_start + 48),
        (60, ground_start + 50), (42, ground_start + 55),
    ]
    for tx, ty in tuft_positions:
        if tx < pw and ty < ph:
            c = [pal["grass_tuft"], pal["grass_tuft2"], pal["grass_tuft3"]][
                (tx + ty) % 3]
            draw_pixel_rect(draw, tx, ty, 1, 1, c)
            draw_pixel_rect(draw, tx + 1, ty - 1, 1, 1, c)
            if (tx + ty) % 2 == 0:
                draw_pixel_rect(draw, tx - 1, ty, 1, 1, pal["grass_tuft2"])

    # ── 5. Dust particles (subtle atmosphere) ──────────────
    dust_spots = [
        (10, ground_start + 3), (30, ground_start + 9),
        (85, ground_start + 5), (120, ground_start + 16),
        (50, ground_start + 28), (70, ground_start + 12),
    ]
    for dx, dy in dust_spots:
        if dx < pw and dy < ph:
            draw_pixel_rect(draw, dx, dy, 1, 1, pal["dust"])

    return circle_mask(img)


if __name__ == "__main__":
    out_dir = "resources/drawables"
    os.makedirs(out_dir, exist_ok=True)

    print("Generating bg_route_day.png...")
    generate_route("day").save(f"{out_dir}/bg_route_day.png")

    print("Generating bg_route_night.png...")
    generate_route("night").save(f"{out_dir}/bg_route_night.png")

    print("Generating bg_route_sunset.png...")
    generate_route("sunset").save(f"{out_dir}/bg_route_sunset.png")

    print("Generating bg_route_morning.png...")
    generate_route("morning").save(f"{out_dir}/bg_route_morning.png")

    print("Generating bg_battle.png...")
    generate_battle().save(f"{out_dir}/bg_battle.png")

    print("Done! Generated 5 pixel-art backgrounds.")
