#!/bin/bash
# Crops images in the directory from which this script is called

# To replace spaces with _ and delete parentheses from filenames:
# for file in *; do [ -f "$file" ] && mv "$file" "$(echo "$file" | tr ' ' '_' | tr -d '()')"; done

# Default crop values
DEFAULT_WIDTH=1400
DEFAULT_HEIGHT=888
DEFAULT_X=315
DEFAULT_Y=115

# Output directory
DEFAULT_OUTPUT_DIR="cropped"


# Function to display usage
usage() {
    echo "Usage: $0 [-w width] [-h height] [-x x_offset] [-y y_offset]"
    echo "  -w width      Width of the crop area (default: $DEFAULT_WIDTH)"
    echo "  -h height     Height of the crop area (default: $DEFAULT_HEIGHT)"
    echo "  -x x_offset   X offset of the crop area (default: $DEFAULT_X)"
    echo "  -y y_offset   Y offset of the crop area (default: $DEFAULT_Y)"
    echo "  -o output_dir Output directory (default: $DEFAULT_OUTPUT_DIR)"
    exit 1
}

# Parse command-line arguments
while getopts "w:h:x:y:o" opt; do
    case $opt in
        w) WIDTH=$OPTARG ;;
        h) HEIGHT=$OPTARG ;;
        x) X_OFFSET=$OPTARG ;;
        y) Y_OFFSET=$OPTARG ;;
        o) OUTPUT_DIR=$OPTARG ;;
        *) usage ;;
    esac
done

# Set default values if not provided
WIDTH=${WIDTH:-$DEFAULT_WIDTH}
HEIGHT=${HEIGHT:-$DEFAULT_HEIGHT}
X_OFFSET=${X_OFFSET:-$DEFAULT_X}
Y_OFFSET=${Y_OFFSET:-$DEFAULT_Y}
OUTPUT_DIR=${OUTPUT_DIR:-$DEFAULT_OUTPUT_DIR}

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Crop all images in the current directory
for img in *.{jpg,jpeg,png,gif}; do
    if [ -f "$img" ]; then
        convert "$img" -crop "${WIDTH}x${HEIGHT}+${X_OFFSET}+${Y_OFFSET}" "$OUTPUT_DIR/$img"
        echo "Cropped $img..."
    fi
done

echo "All images have been cropped and saved to $OUTPUT_DIR"