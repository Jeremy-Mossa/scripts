from PIL import Image, ImageDraw, ImageFont, ImageEnhance
import os

# Configuration
CANVAS_SIZE = (1280, 720)
CHAMP_PICS_DIR = os.path.expanduser("~/mcoc/champs")
BG_IMAGE = "act6.png"
OUTPUT_FILE = "thumbnail.png"
FONT_PATH = "komika.ttf"  # Replace with system font path if needed
FONT_SIZE_HEADER = 70
FONT_SIZE_ACT = 100  # Larger font for act number
FONT_SIZE_TEAM = 45
FONT_SIZE_FOOTER = 35
FONT_SIZE_VS = 70  # Larger font for VS
FONT_SIZE_BOSS = 30  # Small font for "BOSS" text
FONT_SIZE_NAME = 20  # Tiny font for name labels
REGULAR_PORTRAIT_SIZE = (150, 150)  # Size for regular enemies and champs
BOSS_PORTRAIT_SIZE = (180, 180)  # Larger size for boss (enemy 7)
PADDING = 50  # Padding for left and right justification of header
NUM_CHAMPS = 5
NUM_ENEMIES = 7
FADE_FACTOR = 0.15  # Muted background
BRIGHTNESS_FACTOR = 1.2  # Brightness of champs and enemies
BOSS_TEXT_OFFSET = 40  # Reduced from 50, moving "BOSS" down a few more px
BOSS_Y_OFFSET = -30  # Move boss and enemies up by 30px
VS_Y_OFFSET = 9 # Move VS down by 9px

# Previous inputs (for reloading)
PREVIOUS_CHAMPS = ["magneto", "wags", "gambit", "apocalypse", "jean_grey"]
PREVIOUS_ENEMIES = ["ghost", "elektra", "ddhk", "hood", "ebony_maw", "thanos", "sabretooth"]
PREVIOUS_QUEST = "6.1.1"

# Load fonts with fallback
try:
    font_header = ImageFont.truetype(FONT_PATH, FONT_SIZE_HEADER)
    font_act = ImageFont.truetype(FONT_PATH, FONT_SIZE_ACT)
    font_team = ImageFont.truetype(FONT_PATH, FONT_SIZE_TEAM)
    font_footer = ImageFont.truetype(FONT_PATH, FONT_SIZE_FOOTER)
    font_vs = ImageFont.truetype(FONT_PATH, FONT_SIZE_VS)
    font_boss = ImageFont.truetype(FONT_PATH, FONT_SIZE_BOSS)
    font_name = ImageFont.truetype(FONT_PATH, FONT_SIZE_NAME)
except IOError:
    print("Font not found. Using default system font.")
    font_header = ImageFont.load_default()
    font_act = ImageFont.load_default()
    font_team = ImageFont.load_default()
    font_footer = ImageFont.load_default()
    font_vs = ImageFont.load_default()
    font_boss = ImageFont.load_default()
    font_name = ImageFont.load_default()

# Load and prepare background image with padding and fade
bg = Image.open(BG_IMAGE).convert("RGBA")
if bg.size != CANVAS_SIZE:
    bg_new = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 255))  # Black padding
    bg_x = (CANVAS_SIZE[0] - bg.size[0]) // 2
    bg_y = (CANVAS_SIZE[1] - bg.size[1]) // 2
    bg_new.paste(bg, (bg_x, bg_y), bg)
    bg = bg_new
else:
    bg = bg.resize(CANVAS_SIZE, Image.LANCZOS)

# Apply fade effect to background
bg_pixels = bg.load()
for x in range(CANVAS_SIZE[0]):
    for y in range(CANVAS_SIZE[1]):
        r, g, b, a = bg_pixels[x, y]
        faded_r = int(r * FADE_FACTOR)
        faded_g = int(g * FADE_FACTOR)
        faded_b = int(b * FADE_FACTOR)
        bg_pixels[x, y] = (faded_r, faded_g, faded_b, a)

canvas = Image.new("RGBA", CANVAS_SIZE, (0, 0, 0, 0))
canvas.paste(bg, (0, 0))

# Initialize draw object
draw = ImageDraw.Draw(canvas)

# Option to load previous inputs
use_previous = input("Use previous inputs? (yes/no): ").strip().lower() == "yes"
if use_previous:
    quest = PREVIOUS_QUEST
    champ_names = PREVIOUS_CHAMPS
    enemy_names = PREVIOUS_ENEMIES
else:
    # Prompt for quest name
    quest = input("Enter quest name (e.g., 6.1.1): ").strip()
    # Prompt for champion names
    champ_names = []
    for i in range(NUM_CHAMPS):
        name = input(f"Enter champion {i+1} name (e.g., Hulk): ").strip()
        champ_names.append(name)
    # Prompt for enemy names
    enemy_names = []
    for i in range(NUM_ENEMIES):
        name = input(f"Enter enemy {i+1} name (e.g., Thanos): ").strip()
        enemy_names.append(name)

# Draw header with left-justified act and right-justified "5 STARS ONLY"
header_y = int(CANVAS_SIZE[1] * 0.04) - 5  # Moved up by 5px
# Left-justified "ACT 6.1.1"
act_part = f"ACT {quest}"
act_bbox = draw.textbbox((0, 0), act_part, font=font_act)
act_size = (act_bbox[2] - act_bbox[0], act_bbox[3] - act_bbox[1])
act_x = PADDING  # Left-justified with padding
draw.text((act_x, header_y), act_part, fill="white", font=font_act, stroke_width=2, stroke_fill="black")
# Right-justified "5 STARS ONLY"
arrow_text = "5 STARS ONLY"
arrow_bbox = draw.textbbox((0, 0), arrow_text, font=font_header)
arrow_size = (arrow_bbox[2] - arrow_bbox[0], arrow_bbox[3] - arrow_bbox[1])
arrow_x = CANVAS_SIZE[0] - arrow_size[0] - PADDING  # Right-justified with padding
draw.text((arrow_x, header_y), arrow_text, fill="white", font=font_header, stroke_width=2, stroke_fill="black")

# Draw "TEAM:" text
team_text = "TEAM:"
team_y = int(CANVAS_SIZE[1] * 0.16) - 5  # Moved up by 5px
team_bbox = draw.textbbox((0, 0), team_text, font=font_team)
team_size = (team_bbox[2] - team_bbox[0], team_bbox[3] - team_bbox[1])
team_x = (CANVAS_SIZE[0] - team_size[0]) // 2
draw.text((team_x, team_y), team_text, fill="white", font=font_team, stroke_width=2, stroke_fill="black")

# Place champion portraits with brightness, tighter spacing, and name labels
champ_y = int(CANVAS_SIZE[1] * 0.22) + 5  # Moved down by 5px
champ_spacing = 10  # Tight gap between champs
total_champ_width = NUM_CHAMPS * REGULAR_PORTRAIT_SIZE[0] + (NUM_CHAMPS - 1) * champ_spacing
champ_start_x = (CANVAS_SIZE[0] - total_champ_width) // 2  # Center the entire team
for i, name in enumerate(champ_names):
    champ_path = os.path.join(CHAMP_PICS_DIR, f"{name}.png")
    if not os.path.exists(champ_path):
        print(f"Warning: {champ_path} not found. Skipping.")
        continue
    champ_img = Image.open(champ_path).convert("RGBA").resize(REGULAR_PORTRAIT_SIZE, Image.LANCZOS)
    # Brighten the image
    enhancer = ImageEnhance.Brightness(champ_img)
    champ_img = enhancer.enhance(BRIGHTNESS_FACTOR)
    champ_x = champ_start_x + i * (REGULAR_PORTRAIT_SIZE[0] + champ_spacing)
    canvas.paste(champ_img, (champ_x, champ_y), champ_img)
    # Add name label below portrait
    display_name = name.replace("_", " ").replace("-", " ").title()  # Convert to proper capitalization
    name_bbox = draw.textbbox((0, 0), display_name, font=font_name)
    name_size = (name_bbox[2] - name_bbox[0], name_bbox[3] - name_bbox[1])
    name_x = champ_x + (REGULAR_PORTRAIT_SIZE[0] - name_size[0]) // 2  # Center horizontally
    name_y = champ_y + REGULAR_PORTRAIT_SIZE[1] + 5  # 5px below portrait
    draw.text((name_x, name_y), display_name, fill="white", font=font_name, stroke_width=1, stroke_fill="black")

# Place enemy portraits with brightness and "BOSS" text, ensuring alignment
enemy_y = int(CANVAS_SIZE[1] * 0.65) + BOSS_Y_OFFSET  # Moved up by 30px, same for all enemies
enemy_spacing = (CANVAS_SIZE[0] - (NUM_ENEMIES - 1) * REGULAR_PORTRAIT_SIZE[0] - BOSS_PORTRAIT_SIZE[0]) // (NUM_ENEMIES + 1)
for i, name in enumerate(enemy_names):
    enemy_path = os.path.join(CHAMP_PICS_DIR, f"{name}.png")
    if not os.path.exists(enemy_path):
        print(f"Warning: {enemy_path} not found. Skipping.")
        continue
    # Determine portrait size based on whether it's the boss (enemy 7)
    if i == NUM_ENEMIES - 1:  # Boss is always enemy 7
        portrait_size = BOSS_PORTRAIT_SIZE  # 180x180
    else:
        portrait_size = REGULAR_PORTRAIT_SIZE  # 150x150
    enemy_img = Image.open(enemy_path).convert("RGBA").resize(portrait_size, Image.LANCZOS)
    # Brighten the image
    enhancer = ImageEnhance.Brightness(enemy_img)
    enemy_img = enhancer.enhance(BRIGHTNESS_FACTOR)
    # Adjust enemy_x based on the portrait size to maintain centering and alignment
    if i == NUM_ENEMIES - 1:
        # Recalculate spacing for boss to account for larger size
        total_enemy_width = (NUM_ENEMIES - 1) * REGULAR_PORTRAIT_SIZE[0] + BOSS_PORTRAIT_SIZE[0] + (NUM_ENEMIES - 1) * enemy_spacing
        enemy_start_x = (CANVAS_SIZE[0] - total_enemy_width) // 2
        enemy_x = enemy_start_x + (i * (REGULAR_PORTRAIT_SIZE[0] + enemy_spacing))
    else:
        enemy_x = enemy_spacing * (i + 1) + REGULAR_PORTRAIT_SIZE[0] * i
    canvas.paste(enemy_img, (enemy_x, enemy_y), enemy_img)
    # Add name label below portrait
    display_name = name.replace("_", " ").replace("-", " ").title()  # Convert to proper capitalization
    name_bbox = draw.textbbox((0, 0), display_name, font=font_name)
    name_size = (name_bbox[2] - name_bbox[0], name_bbox[3] - name_bbox[1])
    name_x = enemy_x + (portrait_size[0] - name_size[0]) // 2  # Center horizontally
    name_y = enemy_y + portrait_size[1] + 5  # 5px below portrait
    draw.text((name_x, name_y), display_name, fill="white", font=font_name, stroke_width=1, stroke_fill="black")
    # Add "BOSS" text for the 7th enemy (boss)
    if i == NUM_ENEMIES - 1:
        boss_text = "BOSS"
        boss_bbox = draw.textbbox((0, 0), boss_text, font=font_boss)
        boss_size = (boss_bbox[2] - boss_bbox[0], boss_bbox[3] - boss_bbox[1])
        boss_x = enemy_x + (BOSS_PORTRAIT_SIZE[0] - boss_size[0]) // 2
        boss_y = enemy_y - BOSS_TEXT_OFFSET  # Moved down by reducing offset to 40px
        draw.text((boss_x, boss_y), boss_text, fill="red", font=font_boss, stroke_width=1, stroke_fill="black")

# Draw "VS" text (perfectly centered, moved up by 10px)
vs_bbox = draw.textbbox((0, 0), "VS", font=font_vs)
vs_size = (vs_bbox[2] - vs_bbox[0], vs_bbox[3] - vs_bbox[1])
vs_y = (CANVAS_SIZE[1] - vs_size[1]) // 2 + VS_Y_OFFSET  # Moved up by 10px
vs_x = (CANVAS_SIZE[0] - vs_size[0]) // 2  # Horizontal center
draw.text((vs_x, vs_y), "V", fill="red", font=font_vs, stroke_width=2, stroke_fill="white")
draw.text((vs_x + vs_size[0]//3, vs_y), "S", fill="blue", font=font_vs, stroke_width=2, stroke_fill="white")

# Prompt for footer text
footer_text = input("Enter footer text (will be all caps): ").strip().upper()

# Draw footer
footer_y = int(CANVAS_SIZE[1] * 0.92) - 20
footer_bbox = draw.textbbox((0, 0), footer_text, font=font_footer)
footer_size = (footer_bbox[2] - footer_bbox[0], footer_bbox[3] - footer_bbox[1])
footer_x = (CANVAS_SIZE[0] - footer_size[0]) // 2
draw.text((footer_x, footer_y), footer_text, fill="white", font=font_footer, stroke_width=2, stroke_fill="black")

# Save the thumbnail
canvas.save(OUTPUT_FILE, "PNG")
print(f"Thumbnail saved as {OUTPUT_FILE}")
