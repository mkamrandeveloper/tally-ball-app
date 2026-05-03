from PIL import Image, ImageOps
import os

# Define paths
logo_path = 'assets/images/logo.png'
output_path = 'assets/images/icon_source.png'

# Load image
img = Image.open(logo_path).convert("RGBA")
width, height = img.size

# We want the whole logo to fit inside the circle
# Tally Ball Logo is already mostly square/circular
# We'll crop just a tiny bit to remove any extreme white edges if they exist
left = width * 0.05
top = height * 0.05
right = width * 0.95
bottom = height * 0.95

# Crop
icon = img.crop((left, top, right, bottom))

# Create a WHITE background (removes the "black" look)
background = Image.new("RGBA", (1024, 1024), (255, 255, 255, 255))

# Resize icon to zoom out (800x800 is safer for circular masks than 900x900)
icon_size = 800
icon = icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

# Paste icon onto background
offset = ((1024 - icon_size) // 2, (1024 - icon_size) // 2)
background.paste(icon, offset, icon)

# Save
background.convert("RGB").save(output_path)
print(f"Icon updated with white background and zoomed out at {output_path}")
