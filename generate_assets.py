from PIL import Image, ImageDraw, ImageFont
import os

screenshots = ["screenshot1.jpeg","screenshot2.jpeg","screenshot3.jpeg","screenshot4.jpeg","screenshot5.jpeg","screenshot6.jpeg"]
screenshots = [s for s in screenshots if os.path.exists(s)]
print(f"Found {len(screenshots)} screenshots")

os.makedirs("play_store_assets", exist_ok=True)

# Feature Graphic 1024x500
fg = Image.new("RGB", (1024, 500), color=(213, 43, 30))
draw = ImageDraw.Draw(fg)
try:
    font_big = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 90)
    font_med = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 36)
    font_sml = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 28)
except:
    font_big = ImageFont.load_default()
    font_med = font_big
    font_sml = font_big

def rounded_rect(draw, x1, y1, x2, y2, r, color):
    draw.rectangle([x1+r, y1, x2-r, y2], fill=color)
    draw.rectangle([x1, y1+r, x2, y2-r], fill=color)
    draw.ellipse([x1, y1, x1+r*2, y1+r*2], fill=color)
    draw.ellipse([x2-r*2, y1, x2, y1+r*2], fill=color)
    draw.ellipse([x1, y2-r*2, x1+r*2, y2], fill=color)
    draw.ellipse([x2-r*2, y2-r*2, x2, y2], fill=color)

rounded_rect(draw, 60, 80, 260, 420, 40, (255,255,255))
bb = draw.textbbox((0,0), "G1", font=font_big)
tx = 60 + (200-(bb[2]-bb[0]))//2 - bb[0]
ty = 80 + (340-(bb[3]-bb[1]))//2 - bb[1]
draw.text((tx, ty), "G1", fill=(213,43,30), font=font_big)
draw.text((300, 130), "G1 Ready", fill=(255,255,255), font=font_big)
draw.text((300, 240), "Ontario Driver's Test Prep", fill=(255,200,200), font=font_med)
features = ["80 Practice Questions","Full Exam Simulation","XP & Achievement System"]
for i, f in enumerate(features):
    draw.text((300, 310+i*45), f"• {f}", fill=(255,220,220), font=font_sml)
fg.save("play_store_assets/feature_graphic.png")
print("Saved feature_graphic.png")

sizes = {
    "phone":      (1080, 1920),
    "tablet_7":   (1200, 1920),
    "tablet_10":  (1600, 2560),
    "chromebook": (1920, 1080),
    "android_xr": (1920, 1080),
}

for device, (w, h) in sizes.items():
    os.makedirs(f"play_store_assets/{device}", exist_ok=True)
    for i, fname in enumerate(screenshots):
        img = Image.open(fname).convert("RGB")
        if w > h:
            bg = Image.new("RGB", (w, h), (213, 43, 30))
            ratio = h / img.height
            new_w = int(img.width * ratio)
            resized = img.resize((new_w, h), Image.LANCZOS)
            x_offset = (w - new_w) // 2
            bg.paste(resized, (x_offset, 0))
            bg.save(f"play_store_assets/{device}/screenshot{i+1}.png")
        else:
            resized = img.resize((w, h), Image.LANCZOS)
            resized.save(f"play_store_assets/{device}/screenshot{i+1}.png")
        print(f"Saved {device}/screenshot{i+1}.png")

print("\nAll done! Upload from play_store_assets folder")
