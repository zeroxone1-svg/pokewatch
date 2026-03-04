"""
Download Gen 2 (Johto) Pokémon sprites from PokeAPI, matching Gen 1 style.
Downloads pk152.png through pk251.png as 120x120 RGBA PNGs.
Uses the same sprite source and processing as Gen 1 sprites.
"""
from PIL import Image
import urllib.request
import io
import os
import sys

W, H = 120, 120
OUT_DIR = os.path.join(os.path.dirname(__file__), "resources", "drawables")

# PokeAPI sprite URLs - try multiple sources for best quality pixel art
SPRITE_URLS = [
    # Standard sprites (96x96, clean pixel art from Gen V)
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/{id}.png",
    # Fallback: official artwork style
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{id}.png",
]

GEN2_RANGE = range(152, 252)  # Pokemon 152 (Chikorita) through 251 (Celebi)


def download_sprite(pokemon_id):
    """Download a sprite from PokeAPI, trying multiple sources."""
    for url_template in SPRITE_URLS:
        url = url_template.format(id=pokemon_id)
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "PokeWatch/1.0"})
            with urllib.request.urlopen(req, timeout=15) as response:
                data = response.read()
                img = Image.open(io.BytesIO(data)).convert("RGBA")
                return img
        except Exception as e:
            print(f"  Failed {url}: {e}")
            continue
    return None


def process_sprite(img, target_size=(W, H)):
    """
    Process downloaded sprite to match Gen 1 style:
    - Resize to target size using NEAREST neighbor (preserves pixel art)
    - Ensure transparent background
    """
    # If image is already small pixel art (96x96 or similar), use NEAREST
    # If image is large (official artwork), use LANCZOS then quantize
    if max(img.size) <= 100:
        # Small pixel art sprite - use nearest neighbor to preserve pixels
        resized = img.resize(target_size, Image.NEAREST)
    else:
        # Larger sprite - resize with high quality then reduce colors for pixel look
        resized = img.resize(target_size, Image.LANCZOS)
        # Quantize to limited palette for pixel art feel (like Gen 1's ~13 colors)
        rgb = resized.convert("RGB")
        alpha = resized.split()[3]
        quantized = rgb.quantize(colors=16, method=Image.Quantize.MEDIANCUT)
        result = quantized.convert("RGBA")
        result.putalpha(alpha)
        resized = result

    return resized


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    success = 0
    failed = []

    print(f"Downloading Gen 2 sprites (152-251) to {OUT_DIR}...")
    print()

    for pk_id in GEN2_RANGE:
        filename = f"pk{pk_id:03d}.png"
        filepath = os.path.join(OUT_DIR, filename)

        sys.stdout.write(f"  #{pk_id:03d}... ")
        sys.stdout.flush()

        img = download_sprite(pk_id)
        if img is None:
            print("FAILED")
            failed.append(pk_id)
            continue

        processed = process_sprite(img)
        processed.save(filepath, "PNG")
        success += 1
        print(f"OK ({img.size[0]}x{img.size[1]} -> {W}x{H})")

    print()
    print(f"Done! {success}/{len(GEN2_RANGE)} sprites downloaded to {OUT_DIR}")
    if failed:
        print(f"Failed: {failed}")


if __name__ == "__main__":
    main()
