import qrcode
from PIL import Image, ImageDraw, ImageFilter

# Create the QR Code with optimal settings
qr = qrcode.QRCode(
    version=10,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=15,
    border=5,
)

# Add your data
qr.add_data("https://biteboxx.com")
qr.make(fit=True)

# Create the image with brand colors (dark navy blue for modern look)
img = qr.make_image(fill_color="#1a1a2e", back_color="#FFFFFF")
img = img.convert("RGBA")

# Get QR code dimensions
qr_width, qr_height = img.size

# Apply slight blur to create softer edges
img = img.filter(ImageFilter.GaussianBlur(radius=0.5))
# Then sharpen to maintain clarity
img = img.filter(ImageFilter.SHARPEN)

# Load and process the logo
logo_img = Image.open("assets/image/logo.png").convert("RGBA")

# Calculate optimal logo size (18% of QR code width)
logo_size = int(qr_width * 0.18)
logo_img = logo_img.resize((logo_size, logo_size), Image.Resampling.LANCZOS)

# Create a white circular background with subtle shadow
logo_bg = Image.new('RGBA', (logo_size + 8, logo_size + 8), (255, 255, 255, 0))
draw_bg = ImageDraw.Draw(logo_bg)

# Draw subtle shadow
shadow_offset = 4
draw_bg.ellipse(
    [shadow_offset + 4, shadow_offset + 4, logo_size - shadow_offset, logo_size - shadow_offset],
    fill=(180, 180, 180, 70)
)

# Draw white circle with smooth edges
draw_bg.ellipse(
    [shadow_offset, shadow_offset, logo_size + shadow_offset, logo_size + shadow_offset],
    fill=(255, 255, 255, 255)
)

# Paste the logo onto the white circle
logo_bg.paste(logo_img, (shadow_offset, shadow_offset), logo_img)

# Position the logo in the center
pos = ((qr_width - (logo_size + 8)) // 2, (qr_height - (logo_size + 8)) // 2)

# Paste the logo with background onto the QR code
img.paste(logo_bg, pos, logo_bg)

# Save the file
img.save("biteboxx_qr_code.png", "PNG")
print("QR Code saved successfully as biteboxx_qr_code.png")
print(f"QR Code size: {qr_width}x{qr_height}")
print(f"Logo size: {logo_size}x{logo_size}")
