from PIL import Image, ImageDraw, ImageFont

size = 1024
# Red background
img = Image.new('RGB', (size, size), color=(213, 43, 30))
draw = ImageDraw.Draw(img)

# White rounded rectangle
box_margin = 172
box_x1 = box_margin
box_y1 = box_margin
box_x2 = size - box_margin
box_y2 = size - box_margin
corner_radius = 130

def draw_rounded_rect(draw, x1, y1, x2, y2, radius, color):
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=color)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=color)
    draw.ellipse([x1, y1, x1 + radius*2, y1 + radius*2], fill=color)
    draw.ellipse([x2 - radius*2, y1, x2, y1 + radius*2], fill=color)
    draw.ellipse([x1, y2 - radius*2, x1 + radius*2, y2], fill=color)
    draw.ellipse([x2 - radius*2, y2 - radius*2, x2, y2], fill=color)

draw_rounded_rect(draw, box_x1, box_y1, box_x2, box_y2, corner_radius, (255, 255, 255))

# G1 text in red inside white box
try:
    font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", 300)
except:
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/Arial Bold.ttf", 300)
    except:
        font = ImageFont.load_default()

text = "G1"
bbox = draw.textbbox((0, 0), text, font=font)
tw = bbox[2] - bbox[0]
th = bbox[3] - bbox[1]
tx = (size - tw) // 2 - bbox[0]
ty = (size - th) // 2 - bbox[1] - 20

draw.text((tx, ty), text, fill=(213, 43, 30), font=font)

img.save('assets/images/icon.png')
print("Icon created successfully!")
