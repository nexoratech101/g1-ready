from PIL import Image, ImageDraw, ImageFont
import os

# Create 1024x1024 image
img = Image.new('RGB', (1024, 1024), color=(213, 43, 30))
draw = ImageDraw.Draw(img)

# Draw text
try:
    font_big = ImageFont.truetype("arialbd.ttf", 480)
    font_small = ImageFont.truetype("arialbd.ttf", 130)
except:
    font_big = ImageFont.load_default()
    font_small = ImageFont.load_default()

# G1 text
draw.text((512, 380), "G1", fill="white", font=font_big, anchor="mm")
# READY text  
draw.text((512, 720), "READY", fill="white", font=font_small, anchor="mm")

img.save('assets/images/icon.png')
print("Icon created!")
