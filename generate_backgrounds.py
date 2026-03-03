"""
Generate Game Boy Color-style pixel art backgrounds for PokeWatch.
Creates backgrounds for: main route view, battle encounter view.
Designed for 360x360 round AMOLED display.
Very dark, subtle colors — just enough to see the scene on AMOLED.
Output: RGB PNG with black outside the circle (no alpha transparency).
"""
from PIL import Image, ImageDraw
import math
import random

W, H = 390, 390
CX, CY = W // 2, H // 2
RADIUS = W // 2

# Pixel block size for Game Boy feel
PX = 6  # each "pixel" is 6x6 real pixels

random.seed(42)  # deterministic output

# Dimming factor: multiply all scene colors by this (0.0-1.0)
DIM = 0.45


def dim(color):
    """Reduce brightness for AMOLED."""
    return tuple(max(0, min(255, int(c * DIM))) for c in color)


def fill_rect(draw, x, y, w, h, color):
    """Fill a rectangle aligned to pixel grid."""
    draw.rectangle([x, y, x + w - 1, y + h - 1], fill=color)


def circle_mask_solid(img):
    """Apply circular mask — black outside circle, no transparency."""
    # Create black background
    result = Image.new("RGB", (W, H), (0, 0, 0))
    # Create circle mask
    mask = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(mask)
    # Slightly smaller circle to avoid edge artifacts on round display
    margin = 1
    d.ellipse([margin, margin, W - 1 - margin, H - 1 - margin], fill=255)
    # Paste scene through circle mask
    result.paste(img.convert("RGB"), mask=mask)
    return result


def generate_route_day():
    """Main view background - Route 1 style (day)."""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === SKY (top portion) ===
    for y in range(0, 140, PX):
        t = y / 140.0
        c = dim((8 + int(t * 12), 14 + int(t * 22), 35 + int(t * 40)))
        fill_rect(draw, 0, y, W, PX, c)

    # Clouds
    cloud_color = dim((30, 38, 60))
    cloud_hi = dim((38, 48, 72))
    for cx_c, cy_c in [(80, 30), (92, 30), (104, 30), (86, 24), (98, 24)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_color)
    for cx_c, cy_c in [(86, 18), (92, 18)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_hi)
    for cx_c, cy_c in [(240, 42), (252, 42), (264, 42), (276, 42), (246, 36), (258, 36), (270, 36)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_color)
    for cx_c, cy_c in [(252, 30), (258, 30), (264, 30)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_hi)

    # === DISTANT HILLS ===
    hill_dark = dim((14, 38, 18))
    hill_mid = dim((20, 48, 24))
    for x in range(0, W, PX):
        h_offset = int(math.sin(x * 0.02) * 12 + math.sin(x * 0.035) * 8)
        hill_top = 130 + h_offset
        for y in range(hill_top, 160, PX):
            c = hill_dark if (x // PX + y // PX) % 3 == 0 else hill_mid
            fill_rect(draw, x, y, PX, PX, c)

    # === TREES ===
    tree_positions = [
        (30, 152), (66, 146), (96, 150),
        (252, 148), (288, 144), (318, 152),
        (132, 156), (210, 154),
    ]
    trunk_color = dim((40, 26, 12))
    leaf_dark = dim((18, 48, 22))
    leaf_mid = dim((28, 64, 30))
    leaf_hi = dim((36, 76, 38))

    for tx, ty in tree_positions:
        fill_rect(draw, tx + PX, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx + PX * 2, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx, ty + PX * 2, PX * 4, PX, leaf_dark)
        fill_rect(draw, tx - PX, ty + PX, PX * 5, PX, leaf_mid)
        fill_rect(draw, tx, ty, PX * 4, PX, leaf_mid)
        fill_rect(draw, tx + PX, ty - PX, PX * 2, PX, leaf_hi)

    # === GRASS FIELD ===
    ground_top = 168
    grass_dark = dim((14, 40, 16))
    grass_mid = dim((20, 52, 22))
    grass_light = dim((26, 62, 28))
    grass_hi = dim((32, 72, 34))

    for y in range(ground_top, H, PX):
        for x in range(0, W, PX):
            noise = random.random()
            if noise < 0.1:
                c = grass_hi
            elif noise < 0.3:
                c = grass_light
            elif noise < 0.6:
                c = grass_mid
            else:
                c = grass_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === PATH ===
    path_w = 48
    path_dark = dim((32, 26, 16))
    path_mid = dim((42, 34, 22))
    path_light = dim((52, 42, 28))
    path_edge = dim((22, 38, 20))

    for y in range(ground_top - PX * 2, H, PX):
        t = (y - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        px_start = CX - pw // 2
        px_end = CX + pw // 2
        for x in range(px_start, px_end, PX):
            dist_from_center = abs(x - CX)
            if dist_from_center > pw // 2 - PX:
                c = path_edge
            elif (x // PX + y // PX) % 4 == 0:
                c = path_light
            elif (x // PX + y // PX) % 3 == 0:
                c = path_mid
            else:
                c = path_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === TALL GRASS ===
    tall_grass_color = dim((28, 70, 30))
    tall_grass_tip = dim((38, 82, 38))
    grass_positions = []
    for _ in range(30):
        gx = random.randint(30, W - 40)
        gy = random.randint(ground_top + 20, H - 30)
        t = (gy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(gx - CX) > pw // 2 + PX:
            grass_positions.append((gx, gy))
    for gx, gy in grass_positions:
        fill_rect(draw, gx, gy, PX, PX * 2, tall_grass_color)
        fill_rect(draw, gx, gy - PX, PX, PX, tall_grass_tip)

    # === FLOWERS ===
    flower_colors = [dim((60, 30, 30)), dim((30, 30, 60)), dim((60, 60, 20))]
    for _ in range(8):
        fx = random.randint(40, W - 50)
        fy = random.randint(ground_top + 30, H - 40)
        t = (fy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(fx - CX) > pw // 2 + PX * 2:
            fc = random.choice(flower_colors)
            fill_rect(draw, fx, fy, PX, PX, fc)

    return circle_mask_solid(img)


def generate_route_night():
    """Main view background - Route 1 style (night)."""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === NIGHT SKY ===
    for y in range(0, 140, PX):
        t = y / 140.0
        c = dim((3 + int(t * 5), 3 + int(t * 8), 12 + int(t * 22)))
        fill_rect(draw, 0, y, W, PX, c)

    # Stars
    star_color = dim((60, 60, 90))
    star_bright = dim((90, 90, 130))
    star_positions = [(55, 18), (110, 10), (160, 28), (210, 14), (265, 22),
                      (300, 12), (90, 44), (190, 40), (280, 48), (140, 54)]
    for sx, sy in star_positions:
        c = star_bright if random.random() > 0.5 else star_color
        fill_rect(draw, sx, sy, 3, 3, c)

    # Moon
    fill_rect(draw, 275, 24, PX * 2, PX * 2, dim((50, 50, 70)))
    fill_rect(draw, 281, 24, PX, PX, dim((70, 70, 90)))

    # === HILLS ===
    hill_dark = dim((6, 18, 10))
    hill_mid = dim((10, 24, 14))
    for x in range(0, W, PX):
        h_offset = int(math.sin(x * 0.02) * 12 + math.sin(x * 0.035) * 8)
        hill_top = 130 + h_offset
        for y in range(hill_top, 160, PX):
            c = hill_dark if (x // PX + y // PX) % 3 == 0 else hill_mid
            fill_rect(draw, x, y, PX, PX, c)

    # === TREES ===
    tree_positions = [
        (30, 152), (66, 146), (96, 150),
        (252, 148), (288, 144), (318, 152),
        (132, 156), (210, 154),
    ]
    trunk_color = dim((22, 14, 6))
    leaf_dark = dim((8, 26, 10))
    leaf_mid = dim((14, 36, 16))
    leaf_hi = dim((20, 44, 22))

    for tx, ty in tree_positions:
        fill_rect(draw, tx + PX, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx + PX * 2, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx, ty + PX * 2, PX * 4, PX, leaf_dark)
        fill_rect(draw, tx - PX, ty + PX, PX * 5, PX, leaf_mid)
        fill_rect(draw, tx, ty, PX * 4, PX, leaf_mid)
        fill_rect(draw, tx + PX, ty - PX, PX * 2, PX, leaf_hi)

    # === GRASS FIELD ===
    ground_top = 168
    grass_dark = dim((6, 20, 8))
    grass_mid = dim((10, 28, 12))
    grass_light = dim((14, 36, 16))
    grass_hi = dim((18, 42, 20))

    random.seed(42)
    for y in range(ground_top, H, PX):
        for x in range(0, W, PX):
            noise = random.random()
            if noise < 0.1:
                c = grass_hi
            elif noise < 0.3:
                c = grass_light
            elif noise < 0.6:
                c = grass_mid
            else:
                c = grass_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === PATH ===
    path_w = 48
    path_dark = dim((18, 14, 8))
    path_mid = dim((24, 18, 10))
    path_light = dim((30, 22, 14))
    path_edge = dim((12, 20, 10))

    for y in range(ground_top - PX * 2, H, PX):
        t = (y - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        px_start = CX - pw // 2
        px_end = CX + pw // 2
        for x in range(px_start, px_end, PX):
            dist_from_center = abs(x - CX)
            if dist_from_center > pw // 2 - PX:
                c = path_edge
            elif (x // PX + y // PX) % 4 == 0:
                c = path_light
            elif (x // PX + y // PX) % 3 == 0:
                c = path_mid
            else:
                c = path_dark
            fill_rect(draw, x, y, PX, PX, c)

    # Tall grass
    tall_grass = dim((16, 40, 18))
    tall_tip = dim((22, 48, 24))
    random.seed(55)
    for _ in range(20):
        gx = random.randint(30, W - 40)
        gy = random.randint(ground_top + 20, H - 30)
        t = (gy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(gx - CX) > pw // 2 + PX:
            fill_rect(draw, gx, gy, PX, PX * 2, tall_grass)
            fill_rect(draw, gx, gy - PX, PX, PX, tall_tip)

    return circle_mask_solid(img)


def generate_route_sunset():
    """Main view background - Route 1 style (sunset)."""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === SUNSET SKY ===
    for y in range(0, 140, PX):
        t = y / 140.0
        c = dim((18 + int(t * 28), 6 + int(t * 14), 8 + int(t * 16)))
        fill_rect(draw, 0, y, W, PX, c)

    # Sun glow
    sun_colors = [dim((60, 36, 14)), dim((50, 28, 10)), dim((40, 22, 8))]
    for i, sc in enumerate(sun_colors):
        radius = (3 - i) * PX
        sx, sy = 280, 60
        for dy in range(-radius, radius + 1, PX):
            for dx in range(-radius, radius + 1, PX):
                if dx * dx + dy * dy <= radius * radius:
                    fill_rect(draw, sx + dx, sy + dy, PX, PX, sc)

    # Clouds
    cloud_color = dim((44, 26, 20))
    cloud_hi = dim((52, 32, 24))
    for cx_c, cy_c in [(60, 40), (72, 40), (84, 40), (66, 34), (78, 34)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_color)
    for cx_c, cy_c in [(180, 50), (192, 50), (204, 50), (216, 50), (186, 44), (198, 44)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_hi)

    # === HILLS ===
    hill_dark = dim((16, 26, 12))
    hill_mid = dim((22, 32, 16))
    for x in range(0, W, PX):
        h_offset = int(math.sin(x * 0.02) * 12 + math.sin(x * 0.035) * 8)
        hill_top = 130 + h_offset
        for y in range(hill_top, 160, PX):
            c = hill_dark if (x // PX + y // PX) % 3 == 0 else hill_mid
            fill_rect(draw, x, y, PX, PX, c)

    # === TREES ===
    tree_positions = [
        (30, 152), (66, 146), (96, 150),
        (252, 148), (288, 144), (318, 152),
        (132, 156), (210, 154),
    ]
    trunk_color = dim((34, 20, 8))
    leaf_dark = dim((18, 38, 14))
    leaf_mid = dim((26, 48, 20))
    leaf_hi = dim((32, 56, 26))

    for tx, ty in tree_positions:
        fill_rect(draw, tx + PX, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx + PX * 2, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx, ty + PX * 2, PX * 4, PX, leaf_dark)
        fill_rect(draw, tx - PX, ty + PX, PX * 5, PX, leaf_mid)
        fill_rect(draw, tx, ty, PX * 4, PX, leaf_mid)
        fill_rect(draw, tx + PX, ty - PX, PX * 2, PX, leaf_hi)

    # === GRASS FIELD ===
    ground_top = 168
    grass_dark = dim((14, 32, 12))
    grass_mid = dim((20, 42, 18))
    grass_light = dim((26, 52, 22))
    grass_hi = dim((32, 60, 26))

    random.seed(42)
    for y in range(ground_top, H, PX):
        for x in range(0, W, PX):
            noise = random.random()
            if noise < 0.1:
                c = grass_hi
            elif noise < 0.3:
                c = grass_light
            elif noise < 0.6:
                c = grass_mid
            else:
                c = grass_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === PATH ===
    path_w = 48
    path_dark = dim((28, 20, 12))
    path_mid = dim((38, 26, 16))
    path_light = dim((48, 34, 20))
    path_edge = dim((20, 32, 16))

    for y in range(ground_top - PX * 2, H, PX):
        t = (y - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        px_start = CX - pw // 2
        px_end = CX + pw // 2
        for x in range(px_start, px_end, PX):
            dist_from_center = abs(x - CX)
            if dist_from_center > pw // 2 - PX:
                c = path_edge
            elif (x // PX + y // PX) % 4 == 0:
                c = path_light
            elif (x // PX + y // PX) % 3 == 0:
                c = path_mid
            else:
                c = path_dark
            fill_rect(draw, x, y, PX, PX, c)

    # Tall grass
    tall_grass = dim((28, 60, 24))
    tall_tip = dim((36, 70, 30))
    random.seed(55)
    for _ in range(20):
        gx = random.randint(30, W - 40)
        gy = random.randint(ground_top + 20, H - 30)
        t = (gy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(gx - CX) > pw // 2 + PX:
            fill_rect(draw, gx, gy, PX, PX * 2, tall_grass)
            fill_rect(draw, gx, gy - PX, PX, PX, tall_tip)

    return circle_mask_solid(img)


def generate_battle_bg():
    """Encounter/battle background - classic Pokemon battle field."""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === DARK GRADIENT SKY ===
    for y in range(0, 100, PX):
        t = y / 100.0
        c = dim((4 + int(t * 8), 6 + int(t * 10), 14 + int(t * 20)))
        fill_rect(draw, 0, y, W, PX, c)

    # === BATTLE ARENA GROUND ===
    ground_top = 240
    ground_dark = dim((18, 24, 14))
    ground_mid = dim((24, 32, 20))
    ground_light = dim((32, 40, 24))

    random.seed(77)
    for y in range(ground_top, H, PX):
        for x in range(0, W, PX):
            noise = random.random()
            if noise < 0.15:
                c = ground_light
            elif noise < 0.4:
                c = ground_mid
            else:
                c = ground_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === BATTLE PLATFORM ===
    plat_y = ground_top - 12
    plat_w = 160
    plat_x = CX - plat_w // 2

    shadow_color = dim((14, 18, 10))
    fill_rect(draw, plat_x + PX, plat_y + PX * 2, plat_w - PX * 2, PX, shadow_color)
    plat_top = dim((30, 38, 22))
    plat_mid = dim((24, 32, 20))
    plat_edge = dim((18, 26, 16))
    fill_rect(draw, plat_x, plat_y, plat_w, PX * 2, plat_mid)
    fill_rect(draw, plat_x + PX, plat_y - PX, plat_w - PX * 2, PX, plat_top)
    fill_rect(draw, plat_x, plat_y, PX, PX * 2, plat_edge)
    fill_rect(draw, plat_x + plat_w - PX, plat_y, PX, PX * 2, plat_edge)
    for x in range(plat_x + PX, plat_x + plat_w - PX, PX * 2):
        fill_rect(draw, x, plat_y, PX, PX, plat_top)

    # === GRASS around arena ===
    tg_dark = dim((12, 38, 16))
    tg_mid = dim((18, 50, 22))
    tg_hi = dim((24, 58, 28))

    random.seed(88)
    for _ in range(12):
        gx = random.randint(30, plat_x - 20)
        gy = random.randint(ground_top - 20, H - 30)
        fill_rect(draw, gx, gy, PX, PX * 2, tg_mid)
        fill_rect(draw, gx, gy - PX, PX, PX, tg_hi)
    for _ in range(12):
        gx = random.randint(plat_x + plat_w + 10, W - 40)
        gy = random.randint(ground_top - 20, H - 30)
        fill_rect(draw, gx, gy, PX, PX * 2, tg_mid)
        fill_rect(draw, gx, gy - PX, PX, PX, tg_hi)

    # === ROCKS ===
    rock_dark = dim((22, 22, 22))
    rock_mid = dim((30, 30, 30))
    rock_hi = dim((38, 38, 38))
    fill_rect(draw, 40, ground_top + 12, PX * 3, PX * 2, rock_dark)
    fill_rect(draw, 40 + PX, ground_top + 6, PX * 2, PX, rock_mid)
    fill_rect(draw, W - 55, ground_top + 24, PX * 3, PX * 2, rock_dark)
    fill_rect(draw, W - 55 + PX, ground_top + 18, PX * 2, PX, rock_mid)
    fill_rect(draw, 90, ground_top + 40, PX * 2, PX, rock_dark)

    # === BUSHES ===
    bush_dark = dim((10, 28, 14))
    bush_mid = dim((16, 38, 20))
    bush_hi = dim((22, 46, 26))
    fill_rect(draw, 10, ground_top - 18, PX * 4, PX * 3, bush_dark)
    fill_rect(draw, 10 + PX, ground_top - 24, PX * 3, PX, bush_mid)
    fill_rect(draw, W - PX * 5, ground_top - 18, PX * 4, PX * 3, bush_dark)
    fill_rect(draw, W - PX * 4, ground_top - 24, PX * 3, PX, bush_mid)

    # Horizon line
    line_color = dim((28, 36, 22))
    fill_rect(draw, 50, ground_top - 2, W - 100, 2, line_color)

    return circle_mask_solid(img)


def generate_morning_route():
    """Main view background - Route 1 style (morning)."""
    img = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # === MORNING SKY ===
    for y in range(0, 140, PX):
        t = y / 140.0
        c = dim((10 + int(t * 18), 10 + int(t * 16), 20 + int(t * 32)))
        fill_rect(draw, 0, y, W, PX, c)

    # Morning sun
    fill_rect(draw, 70, 70, PX * 2, PX * 2, dim((50, 40, 16)))
    fill_rect(draw, 76, 70, PX, PX, dim((62, 48, 22)))
    # Sun rays
    ray_color = dim((34, 28, 14))
    for rx, ry in [(56, 76), (92, 64), (82, 58)]:
        fill_rect(draw, rx, ry, PX, PX, ray_color)

    # Clouds
    cloud_color = dim((28, 30, 48))
    for cx_c, cy_c in [(180, 30), (192, 30), (204, 30), (186, 24), (198, 24)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_color)
    for cx_c, cy_c in [(280, 46), (292, 46), (304, 46), (286, 40)]:
        fill_rect(draw, cx_c, cy_c, PX, PX, cloud_color)

    # === HILLS ===
    hill_dark = dim((12, 30, 14))
    hill_mid = dim((18, 38, 20))
    for x in range(0, W, PX):
        h_offset = int(math.sin(x * 0.02) * 12 + math.sin(x * 0.035) * 8)
        hill_top = 130 + h_offset
        for y in range(hill_top, 160, PX):
            c = hill_dark if (x // PX + y // PX) % 3 == 0 else hill_mid
            fill_rect(draw, x, y, PX, PX, c)

    # === TREES ===
    tree_positions = [
        (30, 152), (66, 146), (96, 150),
        (252, 148), (288, 144), (318, 152),
        (132, 156), (210, 154),
    ]
    trunk_color = dim((36, 22, 8))
    leaf_dark = dim((14, 42, 16))
    leaf_mid = dim((22, 56, 24))
    leaf_hi = dim((30, 68, 32))

    for tx, ty in tree_positions:
        fill_rect(draw, tx + PX, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx + PX * 2, ty + PX * 3, PX, PX * 2, trunk_color)
        fill_rect(draw, tx, ty + PX * 2, PX * 4, PX, leaf_dark)
        fill_rect(draw, tx - PX, ty + PX, PX * 5, PX, leaf_mid)
        fill_rect(draw, tx, ty, PX * 4, PX, leaf_mid)
        fill_rect(draw, tx + PX, ty - PX, PX * 2, PX, leaf_hi)

    # === GRASS FIELD ===
    ground_top = 168
    grass_dark = dim((12, 36, 14))
    grass_mid = dim((18, 48, 20))
    grass_light = dim((24, 58, 26))
    grass_hi = dim((28, 66, 30))

    random.seed(42)
    for y in range(ground_top, H, PX):
        for x in range(0, W, PX):
            noise = random.random()
            if noise < 0.1:
                c = grass_hi
            elif noise < 0.3:
                c = grass_light
            elif noise < 0.6:
                c = grass_mid
            else:
                c = grass_dark
            fill_rect(draw, x, y, PX, PX, c)

    # === PATH ===
    path_w = 48
    path_dark = dim((28, 22, 12))
    path_mid = dim((38, 28, 16))
    path_light = dim((46, 36, 22))
    path_edge = dim((20, 34, 18))

    for y in range(ground_top - PX * 2, H, PX):
        t = (y - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        px_start = CX - pw // 2
        px_end = CX + pw // 2
        for x in range(px_start, px_end, PX):
            dist_from_center = abs(x - CX)
            if dist_from_center > pw // 2 - PX:
                c = path_edge
            elif (x // PX + y // PX) % 4 == 0:
                c = path_light
            elif (x // PX + y // PX) % 3 == 0:
                c = path_mid
            else:
                c = path_dark
            fill_rect(draw, x, y, PX, PX, c)

    # Tall grass
    tall_grass = dim((24, 62, 26))
    tall_tip = dim((32, 72, 34))
    random.seed(55)
    for _ in range(20):
        gx = random.randint(30, W - 40)
        gy = random.randint(ground_top + 20, H - 30)
        t = (gy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(gx - CX) > pw // 2 + PX:
            fill_rect(draw, gx, gy, PX, PX * 2, tall_grass)
            fill_rect(draw, gx, gy - PX, PX, PX, tall_tip)

    # Flowers
    flower_colors = [dim((56, 34, 24)), dim((48, 24, 42)), dim((56, 56, 20))]
    random.seed(99)
    for _ in range(8):
        fx = random.randint(40, W - 50)
        fy = random.randint(ground_top + 30, H - 40)
        t = (fy - ground_top) / max(1, (H - ground_top))
        pw = int(path_w + t * 30)
        if abs(fx - CX) > pw // 2 + PX * 2:
            fc = random.choice(flower_colors)
            fill_rect(draw, fx, fy, PX, PX, fc)

    return circle_mask_solid(img)


if __name__ == "__main__":
    out_dir = "resources/drawables"

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

    print("Done! Generated 5 background images.")
