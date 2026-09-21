from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
source = root / "临时" / "S05_render"
target = root / "原文" / "图表" / "S05"
files = sorted(source.glob("slide-*.png"))
font = ImageFont.load_default()
per_sheet = 20
cols, rows = 4, 5
thumb_w, thumb_h = 360, 230
label_h = 22

for offset in range(0, len(files), per_sheet):
    group = files[offset:offset + per_sheet]
    canvas = Image.new("RGB", (cols * thumb_w, rows * (thumb_h + label_h)), "white")
    draw = ImageDraw.Draw(canvas)
    for local_index, path in enumerate(group):
        image = Image.open(path).convert("RGB")
        image.thumbnail((thumb_w - 8, thumb_h - 8))
        col = local_index % cols
        row = local_index // cols
        x = col * thumb_w + (thumb_w - image.width) // 2
        y = row * (thumb_h + label_h) + (thumb_h - image.height) // 2
        canvas.paste(image, (x, y))
        page = offset + local_index + 1
        draw.text((col * thumb_w + 6, row * (thumb_h + label_h) + thumb_h + 2), f"PDF page {page}", fill="black", font=font)
    first_page = offset + 1
    last_page = offset + len(group)
    out = target / f"S05_contact_{first_page:03d}-{last_page:03d}.png"
    canvas.save(out, optimize=True)

print(f"source_pages={len(files)}")
print(f"contact_sheets={len(list(target.glob('S05_contact_*.png')))}")
