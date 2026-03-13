#!/usr/bin/env python3
"""Generate a 1024x1024 app icon for RecipePlanner.

Usage:
    python3 scripts/generate_icon.py [output_path]

Default output: RecipePlanner/Assets.xcassets/AppIcon.appiconset/icon.png
"""

import math
import os
import subprocess
import sys

VENV_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), ".venv")


def ensure_pillow():
    """Create a venv and install Pillow if needed, then activate it."""
    if not os.path.isdir(VENV_DIR):
        print(f"Creating venv at {VENV_DIR}...")
        subprocess.check_call([sys.executable, "-m", "venv", VENV_DIR])

    if sys.platform == "win32":
        site_packages_glob = os.path.join(VENV_DIR, "Lib", "site-packages")
    else:
        lib_dir = os.path.join(VENV_DIR, "lib")
        py_dirs = [d for d in os.listdir(lib_dir) if d.startswith("python")] if os.path.isdir(lib_dir) else []
        if not py_dirs:
            raise RuntimeError(f"No python directory found in {lib_dir}")
        site_packages_glob = os.path.join(lib_dir, py_dirs[0], "site-packages")

    if site_packages_glob not in sys.path:
        sys.path.insert(0, site_packages_glob)

    try:
        import PIL  # noqa: F401
    except ImportError:
        print("Installing Pillow into venv...")
        pip = os.path.join(VENV_DIR, "bin", "pip")
        req = os.path.join(os.path.dirname(os.path.abspath(__file__)), "requirements.txt")
        subprocess.check_call([pip, "install", "-r", req])


ensure_pillow()

from PIL import Image, ImageDraw  # noqa: E402

SIZE = 1024
DEFAULT_OUTPUT = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "RecipePlanner",
    "Assets.xcassets",
    "AppIcon.appiconset",
    "icon.png",
)


def lerp_color(c1, c2, t):
    """Linearly interpolate between two RGB colors."""
    return tuple(int(a + (b - a) * t) for a, b in zip(c1, c2))


def draw_gradient(draw, size, top_color, bottom_color):
    """Draw a vertical gradient background."""
    for y in range(size):
        color = lerp_color(top_color, bottom_color, y / size)
        draw.line([(0, y), (size, y)], fill=color)


def draw_plate(draw, cx, cy, radius):
    """Draw a circular plate with a subtle rim."""
    # Plate shadow
    draw.ellipse(
        [cx - radius + 8, cy - radius + 8, cx + radius + 8, cy + radius + 8],
        fill=(40, 80, 60),
    )
    # Outer rim
    draw.ellipse(
        [cx - radius, cy - radius, cx + radius, cy + radius],
        fill=(255, 255, 255),
    )
    # Inner plate
    inner = radius - 20
    draw.ellipse(
        [cx - inner, cy - inner, cx + inner, cy + inner],
        fill=(245, 245, 240),
    )


def draw_fork(draw, cx, cy, scale=1.0):
    """Draw a stylized fork to the left of the plate."""
    x = cx - int(200 * scale)
    top = cy - int(180 * scale)
    bottom = cy + int(220 * scale)
    w = int(12 * scale)
    tine_len = int(100 * scale)
    gap = int(18 * scale)
    color = (180, 180, 180)

    # Handle
    draw.rounded_rectangle(
        [x - w, cy - int(20 * scale), x + w, bottom],
        radius=int(6 * scale),
        fill=color,
    )
    # Tines
    for offset in [-2 * gap, -gap, 0, gap, 2 * gap]:
        tx = x + offset
        draw.rounded_rectangle(
            [tx - int(4 * scale), top, tx + int(4 * scale), top + tine_len],
            radius=int(3 * scale),
            fill=color,
        )
    # Bridge connecting tines to handle
    draw.rounded_rectangle(
        [x - 2 * gap - int(4 * scale), top + tine_len, x + 2 * gap + int(4 * scale), cy - int(20 * scale)],
        radius=int(6 * scale),
        fill=color,
    )


def draw_knife(draw, cx, cy, scale=1.0):
    """Draw a stylized knife to the right of the plate."""
    x = cx + int(200 * scale)
    top = cy - int(180 * scale)
    bottom = cy + int(220 * scale)
    w = int(12 * scale)
    color = (180, 180, 180)

    # Handle
    draw.rounded_rectangle(
        [x - w, cy + int(20 * scale), x + w, bottom],
        radius=int(6 * scale),
        fill=color,
    )
    # Blade
    blade_w = int(22 * scale)
    draw.rounded_rectangle(
        [x - blade_w, top, x + int(4 * scale), cy + int(30 * scale)],
        radius=int(8 * scale),
        fill=color,
    )


def draw_steam(draw, cx, cy, scale=1.0):
    """Draw wavy steam lines above the plate."""
    color = (255, 255, 255, 140)
    for i, x_offset in enumerate([-40, 0, 40]):
        x_base = cx + int(x_offset * scale)
        y_start = cy - int((180 + i * 15) * scale)
        points = []
        for step in range(20):
            t = step / 19
            y = y_start - int(80 * scale * t)
            x = x_base + int(15 * scale * math.sin(t * math.pi * 2 + i))
            points.append((x, y))
        if len(points) >= 2:
            draw.line(points, fill=color, width=int(4 * scale))


def generate_icon(output_path):
    """Generate the RecipePlanner app icon."""
    img = Image.new("RGBA", (SIZE, SIZE))
    draw = ImageDraw.Draw(img)

    # Gradient background — warm green tones (cooking/fresh theme)
    draw_gradient(draw, SIZE, top_color=(72, 165, 120), bottom_color=(45, 110, 85))

    cx, cy = SIZE // 2, SIZE // 2 + 30

    # Plate
    draw_plate(draw, cx, cy, radius=220)

    # Utensils
    draw_fork(draw, cx, cy, scale=1.0)
    draw_knife(draw, cx, cy, scale=1.0)

    # Steam (suggests a hot meal / recipe)
    draw_steam(draw, cx, cy - 30, scale=1.0)

    # Flatten to RGB (no alpha in final icon)
    final = Image.new("RGB", (SIZE, SIZE))
    final.paste(img, mask=img.split()[3])

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    final.save(output_path, "PNG")
    print(f"Generated {SIZE}x{SIZE} app icon: {output_path}")


if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_OUTPUT
    generate_icon(output)
