#!/bin/ksh

# Directory containing the fake .png files (HTML files)
IMAGES_DIR=~/champs_images

# Check if the directory exists
if [ ! -d "$IMAGES_DIR" ]; then
    echo "Error: Directory $IMAGES_DIR does not exist."
    exit 1
fi

# Loop through all .png files in the images directory
for file in "$IMAGES_DIR"/*.png; do
    # Check if there are any .png files
    if [ ! -f "$file" ]; then
        echo "No .png files found in $IMAGES_DIR"
        exit 0
    fi

    # Extract the image URL from the HTML file
    image_url=$(grep -o 'https://static.wikia.nocookie.net/marvel-contestofchampions/images/[^"]*_portrait.png' "$file" | head -1)

    if [ -n "$image_url" ]; then
        echo "Found image URL for $(basename "$file"): $image_url"

        # Download the real image to a temporary file
        temp_file="$IMAGES_DIR/temp_$(basename "$file")"
        wget --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" -O "$temp_file" "$image_url" 2>/dev/null

        # Check if the download was successful
        if [ $? -eq 0 ]; then
            # Replace the fake .png file with the real one
            mv "$temp_file" "$file"
            echo "Successfully replaced: $(basename "$file")"
        else
            echo "Failed to download image for: $(basename "$file")"
            rm -f "$temp_file"  # Clean up temp file on failure
        fi
    else
        echo "No image URL found in: $(basename "$file")"
    fi
done
